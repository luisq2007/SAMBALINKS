import 'dart:convert';

import '../../../core/network/http_client.dart';
import '../../links/domain/enums.dart';
import '../domain/metadata_provider.dart';
import 'metadata_strategy.dart';

typedef OEmbedEndpointResolver = Uri? Function(Uri target);

class OEmbedStrategy implements MetadataStrategy {
  OEmbedStrategy(
    this._client, {
    OEmbedEndpointResolver endpointResolver = defaultOEmbedEndpoint,
  }) : _endpointResolver = endpointResolver;

  final SafeHttpClient _client;
  final OEmbedEndpointResolver _endpointResolver;

  @override
  Future<MetadataResult?> fetch(Uri url) async {
    final Uri? endpoint = _endpointResolver(url);
    if (endpoint == null) {
      return null;
    }

    try {
      final SafeHttpResponse response = await _client.get(endpoint);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final Object? decoded = jsonDecode(response.decodeText());
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final String? title = _text(decoded['title']);
      final String? description = _text(decoded['description']);
      final String? image = _absoluteUrl(url, _text(decoded['thumbnail_url']));
      final String? siteName = _text(decoded['provider_name']);
      if (title == null && description == null && image == null) {
        return null;
      }

      return MetadataResult(
        title: title,
        description: description,
        imageUrl: image,
        siteName: siteName,
        resolvedUrl: url,
        status: _statusFor(title, description, image),
      );
    } on Object {
      // oEmbed es best-effort. La cadena debe continuar con HTML ante red,
      // JSON inválido o límites de descarga.
      return null;
    }
  }

  static Uri? defaultOEmbedEndpoint(Uri target) {
    final String host = _normalizedHost(target.host);
    Uri? endpoint;

    if (host == 'youtube.com' || host == 'youtu.be') {
      endpoint = Uri.https('www.youtube.com', '/oembed');
    } else if (host == 'vimeo.com' || host.endsWith('.vimeo.com')) {
      endpoint = Uri.https('vimeo.com', '/api/oembed.json');
    } else if (host == 'reddit.com' || host.endsWith('.reddit.com')) {
      endpoint = Uri.https('www.reddit.com', '/oembed');
    } else if (host == 'tiktok.com' || host.endsWith('.tiktok.com')) {
      endpoint = Uri.https('www.tiktok.com', '/oembed');
    } else if (host == 'flickr.com' || host.endsWith('.flickr.com')) {
      endpoint = Uri.https('www.flickr.com', '/services/oembed/');
    }

    if (endpoint == null) {
      return null;
    }
    return endpoint.replace(
      queryParameters: <String, String>{
        'url': target.toString(),
        'format': 'json',
      },
    );
  }

  static String _normalizedHost(String host) {
    final String lower = host.toLowerCase();
    return lower.startsWith('www.') ? lower.substring(4) : lower;
  }

  static String? _text(Object? value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _absoluteUrl(Uri base, String? value) {
    if (value == null) {
      return null;
    }
    final Uri? parsed = Uri.tryParse(value);
    if (parsed == null) {
      return null;
    }
    return base.resolveUri(parsed).toString();
  }

  static MetadataStatus _statusFor(
    String? title,
    String? description,
    String? image,
  ) {
    return title != null && description != null && image != null
        ? MetadataStatus.ok
        : MetadataStatus.partial;
  }
}
