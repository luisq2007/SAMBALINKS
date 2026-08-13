import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

abstract final class HttpLimits {
  static const int metadataBytes = 512 * 1024;
  static const int previewImageBytes = 2 * 1024 * 1024;
  static const int redirects = 5;
  static const Duration timeout = Duration(seconds: 8);
}

const String defaultDesktopUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/124.0 Safari/537.36 SambaLinks/1.0';

/// Crea el único tipo de cliente Dio que usa el servicio de metadata.
Dio createMetadataDio({String userAgent = defaultDesktopUserAgent}) {
  return Dio(
    BaseOptions(
      connectTimeout: HttpLimits.timeout,
      sendTimeout: HttpLimits.timeout,
      receiveTimeout: HttpLimits.timeout,
      headers: <String, Object>{
        'User-Agent': userAgent,
        'Accept-Language': 'es-ES,es;q=0.9',
        'Accept':
            'text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8',
      },
    ),
  );
}

class HttpBodyTooLargeException implements Exception {
  const HttpBodyTooLargeException({
    required this.maximumBytes,
    required this.acceptedBytes,
  });

  final int maximumBytes;
  final int acceptedBytes;

  @override
  String toString() =>
      'La respuesta excede $maximumBytes bytes (se aceptaron $acceptedBytes).';
}

class SafeHttpResponse {
  const SafeHttpResponse({
    required this.statusCode,
    required this.resolvedUri,
    required this.headers,
    required this.body,
  });

  final int statusCode;
  final Uri resolvedUri;
  final Map<String, List<String>> headers;
  final Uint8List body;

  String? header(String name) => headers[name.toLowerCase()]?.firstOrNull;

  String decodeText() {
    final String contentType = header('content-type')?.toLowerCase() ?? '';
    if (contentType.contains('charset=iso-8859-1') ||
        contentType.contains('charset=latin1')) {
      return latin1.decode(body, allowInvalid: true);
    }
    return utf8.decode(body, allowMalformed: true);
  }
}

/// Lee respuestas como stream y corta la conexión antes de superar el techo.
class SafeHttpClient {
  SafeHttpClient(this._dio);

  final Dio _dio;

  Future<SafeHttpResponse> get(
    Uri uri, {
    int maximumBytes = HttpLimits.metadataBytes,
    Map<String, Object>? headers,
  }) async {
    final CancelToken cancelToken = CancelToken();
    final Response<ResponseBody> response = await _dio.getUri<ResponseBody>(
      uri,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        receiveDataWhenStatusError: true,
        followRedirects: true,
        maxRedirects: HttpLimits.redirects,
        headers: headers,
        validateStatus: (int? _) => true,
      ),
    );

    final int? declaredLength = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    if (declaredLength != null && declaredLength > maximumBytes) {
      cancelToken.cancel('La respuesta supera el límite declarado.');
      throw HttpBodyTooLargeException(
        maximumBytes: maximumBytes,
        acceptedBytes: 0,
      );
    }

    final BytesBuilder bytes = BytesBuilder(copy: false);
    int accepted = 0;
    try {
      await for (final Uint8List chunk
          in response.data?.stream ?? const Stream<Uint8List>.empty()) {
        final int remaining = maximumBytes - accepted;
        if (chunk.length > remaining) {
          if (remaining > 0) {
            bytes.add(Uint8List.sublistView(chunk, 0, remaining));
            accepted += remaining;
          }
          throw HttpBodyTooLargeException(
            maximumBytes: maximumBytes,
            acceptedBytes: accepted,
          );
        }
        bytes.add(chunk);
        accepted += chunk.length;
      }
    } on HttpBodyTooLargeException {
      cancelToken.cancel('La respuesta superó el límite durante la descarga.');
      rethrow;
    }

    return SafeHttpResponse(
      statusCode: response.statusCode ?? 0,
      resolvedUri: response.realUri,
      headers: <String, List<String>>{
        for (final MapEntry<String, List<String>> entry
            in response.headers.map.entries)
          entry.key.toLowerCase(): entry.value,
      },
      body: bytes.takeBytes(),
    );
  }

  /// Resuelve un acortador sin descargar su página de destino completa.
  Future<Uri> resolve(Uri uri) async {
    final Response<String> head = await _dio.headUri<String>(
      uri,
      options: Options(
        responseType: ResponseType.plain,
        receiveDataWhenStatusError: true,
        followRedirects: true,
        maxRedirects: HttpLimits.redirects,
        validateStatus: (int? _) => true,
      ),
    );
    if (head.realUri != uri ||
        (head.statusCode != null &&
            head.statusCode! >= 200 &&
            head.statusCode! < 400)) {
      return head.realUri;
    }

    final CancelToken cancelToken = CancelToken();
    final Response<ResponseBody> response = await _dio.getUri<ResponseBody>(
      uri,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        receiveDataWhenStatusError: true,
        followRedirects: true,
        maxRedirects: HttpLimits.redirects,
        validateStatus: (int? _) => true,
      ),
    );
    final StreamSubscription<Uint8List>? subscription = response.data?.stream
        .listen((Uint8List _) {});
    await subscription?.cancel();
    cancelToken.cancel('Sólo se necesitaba la URL final.');
    return response.realUri;
  }
}
