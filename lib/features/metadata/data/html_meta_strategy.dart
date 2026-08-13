import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../core/network/http_client.dart';
import '../../links/domain/enums.dart';
import '../../links/domain/platform_detector.dart';
import '../domain/metadata_provider.dart';
import 'metadata_strategy.dart';

class HtmlMetaStrategy implements MetadataStrategy {
  HtmlMetaStrategy(this._client);

  final SafeHttpClient _client;

  @override
  Future<MetadataResult?> fetch(Uri url) async {
    try {
      final SafeHttpResponse response = await _client.get(url);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final Document document = html_parser.parse(response.decodeText());
      final Map<String, String> metadata = _metadataOf(document);

      final String? title = _first(<String?>[
        metadata['og:title'],
        metadata['twitter:title'],
        _clean(document.querySelector('title')?.text),
      ]);
      final String? description = _first(<String?>[
        metadata['og:description'],
        metadata['twitter:description'],
        metadata['description'],
      ]);
      final String? image = _resolve(
        response.resolvedUri,
        _first(<String?>[
          metadata['og:image'],
          metadata['og:image:url'],
          metadata['og:image:secure_url'],
          metadata['twitter:image'],
          metadata['twitter:image:src'],
        ]),
      );
      final String? favicon = _favicon(document, response.resolvedUri);
      final String? siteName = _first(<String?>[
        metadata['og:site_name'],
        metadata['application-name'],
      ]);

      if (_isLoginWall(
        document: document,
        url: response.resolvedUri,
        title: title,
        description: description,
      )) {
        return null;
      }
      if (title == null && description == null && image == null) {
        return null;
      }

      return MetadataResult(
        title: title,
        description: description,
        imageUrl: image,
        faviconUrl: favicon,
        siteName: siteName,
        resolvedUrl: response.resolvedUri,
        status: title != null && description != null && image != null
            ? MetadataStatus.ok
            : MetadataStatus.partial,
      );
    } on Object {
      // El parser acepta HTML imperfecto; cualquier otro fallo continúa hacia
      // el fallback garantizado.
      return null;
    }
  }

  static Map<String, String> _metadataOf(Document document) {
    final Map<String, String> result = <String, String>{};
    for (final Element element in document.getElementsByTagName('meta')) {
      final String? key = _clean(
        element.attributes['property'] ?? element.attributes['name'],
      )?.toLowerCase();
      final String? value = _clean(element.attributes['content']);
      if (key != null && value != null) {
        result.putIfAbsent(key, () => value);
      }
    }
    return result;
  }

  static String? _favicon(Document document, Uri base) {
    for (final Element link in document.getElementsByTagName('link')) {
      final Set<String> rel = (link.attributes['rel'] ?? '')
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((String value) => value.isNotEmpty)
          .toSet();
      if (!rel.contains('icon')) {
        continue;
      }
      final String? resolved = _resolve(base, _clean(link.attributes['href']));
      if (resolved != null) {
        return resolved;
      }
    }
    return null;
  }

  static bool _isLoginWall({
    required Document document,
    required Uri url,
    required String? title,
    required String? description,
  }) {
    final LinkPlatform platform = PlatformDetector.detect(url.host);
    if (platform != LinkPlatform.instagram &&
        platform != LinkPlatform.x &&
        platform != LinkPlatform.facebook &&
        platform != LinkPlatform.linkedin) {
      return false;
    }

    final String content = <String?>[
      title,
      description,
      document.body?.text,
    ].whereType<String>().join(' ').toLowerCase();
    const List<String> wallMarkers = <String>[
      'log in to see',
      'login to see',
      'sign up to see',
      'inicia sesión para ver',
      'iniciar sesión para ver',
      'create an account or log in',
      'join linkedin or sign in',
    ];
    if (wallMarkers.any(content.contains)) {
      return true;
    }

    final String compactTitle = title?.toLowerCase().trim() ?? '';
    return compactTitle == 'login • instagram' ||
        compactTitle == 'log in • instagram' ||
        compactTitle == 'iniciar sesión • instagram';
  }

  static String? _resolve(Uri base, String? value) {
    if (value == null) {
      return null;
    }
    final Uri? parsed = Uri.tryParse(value);
    if (parsed == null) {
      return null;
    }
    final Uri resolved = base.resolveUri(parsed);
    if (resolved.scheme != 'http' && resolved.scheme != 'https') {
      return null;
    }
    return resolved.toString();
  }

  static String? _first(List<String?> values) {
    for (final String? value in values) {
      final String? cleaned = _clean(value);
      if (cleaned != null) {
        return cleaned;
      }
    }
    return null;
  }

  static String? _clean(String? value) {
    if (value == null) {
      return null;
    }
    final String cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? null : cleaned;
  }
}
