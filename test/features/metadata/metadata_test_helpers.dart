import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class FixtureResponse {
  const FixtureResponse({
    required this.body,
    this.statusCode = 200,
    this.headers = const <String, List<String>>{
      Headers.contentTypeHeader: <String>['text/html; charset=utf-8'],
    },
    this.chunkSize,
  });

  final List<int> body;
  final int statusCode;
  final Map<String, List<String>> headers;
  final int? chunkSize;

  factory FixtureResponse.text(
    String body, {
    int statusCode = 200,
    Map<String, List<String>>? headers,
  }) {
    return FixtureResponse(
      body: utf8.encode(body),
      statusCode: statusCode,
      headers:
          headers ??
          const <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/html; charset=utf-8'],
          },
    );
  }
}

class FixtureAdapter implements HttpClientAdapter {
  FixtureAdapter(this.handler);

  final FixtureResponse Function(RequestOptions options) handler;
  int requests = 0;
  final List<RequestOptions> seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests += 1;
    seen.add(options);
    final FixtureResponse fixture = handler(options);
    final int chunkSize = fixture.chunkSize ?? fixture.body.length;
    final StreamController<Uint8List> controller =
        StreamController<Uint8List>();
    unawaited(() async {
      for (int offset = 0; offset < fixture.body.length; offset += chunkSize) {
        final int end = (offset + chunkSize).clamp(0, fixture.body.length);
        controller.add(Uint8List.fromList(fixture.body.sublist(offset, end)));
        await Future<void>.delayed(Duration.zero);
      }
      await controller.close();
    }());
    return ResponseBody(
      controller.stream,
      fixture.statusCode,
      headers: fixture.headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio fixtureDio(FixtureAdapter adapter) {
  final Dio dio = Dio();
  dio.httpClientAdapter = adapter;
  return dio;
}
