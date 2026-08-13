import 'enums.dart';
import 'platform_detector.dart';

/// Resultado de normalizar una URL.
class NormalizedUrl {
  const NormalizedUrl({
    required this.original,
    required this.canonical,
    required this.domain,
    required this.platform,
    required this.needsNetworkResolution,
  });

  /// La URL tal como llegó, sólo con el esquema añadido si faltaba.
  final String original;

  /// Forma canónica. Dos URLs que apuntan al mismo contenido producen la
  /// misma cadena: es la base de la detección de duplicados (§27 del PRD).
  final String canonical;

  final String domain;
  final LinkPlatform platform;

  /// La URL es un enlace acortado y su destino real sólo se conoce siguiendo
  /// la redirección. La canónica de ahora es provisional y hay que volver a
  /// comprobar el duplicado tras la petición de red.
  final bool needsNetworkResolution;
}

/// Componentes de una URL mientras se normaliza.
///
/// Se trabaja sobre las piezas y se reconstruye la URI **una sola vez** al
/// final: `Uri.replace` con query o fragmento vacíos los conserva como
/// presentes y acaba serializando cosas como `https://ejemplo.com/a?#`.
class _Parts {
  _Parts({
    required this.scheme,
    required this.host,
    required this.port,
    required this.segments,
    required this.query,
  });

  String scheme;
  String host;
  int? port;
  List<String> segments;
  Map<String, String> query;

  /// La ruta original terminaba en barra.
  bool trailingSlash = false;

  Uri toUri() {
    final String path = segments.isEmpty
        ? (trailingSlash ? '/' : '')
        : '/${segments.join('/')}';

    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: query.isEmpty ? null : query,
    );
  }
}

/// Normalización y canonicalización de URLs.
///
/// Dart puro y sin E/S: es lo que permite tener aquí decenas de casos de
/// prueba sin tocar la red.
abstract final class UrlNormalizer {
  /// Parámetros de seguimiento que nunca identifican contenido.
  static const Set<String> _trackingParams = <String>{
    'fbclid',
    'gclid',
    'igshid',
    'igsh',
    'mc_cid',
    'mc_eid',
    'ref',
    'ref_src',
    'ref_url',
    'si',
    'share_id',
    'source',
    'feature',
    '_branch_match_id',
  };

  /// Acortadores cuyo destino sólo se sabe siguiendo la redirección.
  static const Set<String> _shorteners = <String>{
    'vm.tiktok.com',
    'vt.tiktok.com',
    'pin.it',
    't.co',
    'fb.me',
    'lnkd.in',
    'redd.it',
    'bit.ly',
    'tinyurl.com',
    'ow.ly',
    'buff.ly',
    'rb.gy',
    'shorturl.at',
  };

  /// Plataformas cuya URL identifica el contenido por la ruta, de modo que
  /// cualquier parámetro sobra.
  static const Set<LinkPlatform> _pathOnlyPlatforms = <LinkPlatform>{
    LinkPlatform.instagram,
    LinkPlatform.x,
    LinkPlatform.threads,
    LinkPlatform.reddit,
    LinkPlatform.tiktok,
    LinkPlatform.pinterest,
    LinkPlatform.linkedin,
    LinkPlatform.facebook,
  };

  /// Devuelve `null` sólo si el texto no contiene nada parecido a una URL.
  static NormalizedUrl? normalize(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final Uri? parsed = _parse(trimmed);
    if (parsed == null) {
      return null;
    }

    final String host = PlatformDetector.normalizeHost(parsed.host);
    if (host.isEmpty || !host.contains('.')) {
      return null;
    }

    final LinkPlatform platform = PlatformDetector.detect(host);

    final _Parts parts = _Parts(
      scheme: parsed.scheme.toLowerCase(),
      host: host,
      port: _significantPort(parsed),
      segments: parsed.pathSegments.where((String s) => s.isNotEmpty).toList(),
      query: Map<String, String>.of(parsed.queryParameters),
    )..trailingSlash = parsed.path.endsWith('/');

    _applyPlatformRules(parts, platform);
    _cleanQuery(parts, platform);

    // La barra final sólo se conserva en la raíz.
    if (parts.segments.isNotEmpty) {
      parts.trailingSlash = false;
    }

    return NormalizedUrl(
      original: parsed.toString(),
      canonical: parts.toUri().toString(),
      domain: parts.host,
      platform: platform,
      needsNetworkResolution: _shorteners.contains(host),
    );
  }

  static Uri? _parse(String input) {
    final String withScheme = input.contains('://') ? input : 'https://$input';
    final Uri? uri = Uri.tryParse(withScheme);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return uri;
  }

  /// El puerto por defecto no distingue contenido, así que no entra en la
  /// canónica.
  static int? _significantPort(Uri uri) {
    if (!uri.hasPort) {
      return null;
    }
    final bool isDefault =
        (uri.scheme == 'https' && uri.port == 443) ||
        (uri.scheme == 'http' && uri.port == 80);
    return isDefault ? null : uri.port;
  }

  static void _applyPlatformRules(_Parts parts, LinkPlatform platform) {
    switch (platform) {
      case LinkPlatform.youtube:
        _youtube(parts);
      case LinkPlatform.x:
        _x(parts);
      case LinkPlatform.instagram:
        _instagram(parts);
      case LinkPlatform.reddit:
        _reddit(parts);
      case LinkPlatform.facebook:
        parts.host = 'facebook.com';
      case LinkPlatform.threads:
      case LinkPlatform.pinterest:
      case LinkPlatform.tiktok:
      case LinkPlatform.linkedin:
      case LinkPlatform.web:
      case LinkPlatform.other:
        break;
    }
  }

  /// `youtu.be/ID`, `/shorts/ID` y `/embed/ID` son el mismo vídeo que
  /// `youtube.com/watch?v=ID`.
  static void _youtube(_Parts parts) {
    final List<String> segments = parts.segments;
    String? videoId;

    if (parts.host == 'youtu.be' && segments.isNotEmpty) {
      videoId = segments.first;
    } else if (segments.length >= 2 &&
        <String>['shorts', 'embed', 'v', 'live'].contains(segments.first)) {
      videoId = segments[1];
    } else if (segments.length == 1 && segments.first == 'watch') {
      videoId = parts.query['v'];
    }

    parts.host = 'youtube.com';
    if (videoId == null || videoId.isEmpty) {
      return;
    }
    parts.segments = <String>['watch'];
    parts.query = <String, String>{'v': videoId};
  }

  /// twitter.com y x.com son el mismo sitio. Los sufijos `/photo/1` y
  /// `/video/1` apuntan al mismo tuit.
  static void _x(_Parts parts) {
    parts.host = 'x.com';
    final int mediaIndex = parts.segments.indexWhere(
      (String s) => s == 'photo' || s == 'video',
    );
    if (mediaIndex > 0) {
      parts.segments = parts.segments.sublist(0, mediaIndex);
    }
  }

  /// `instagram.com/{usuario}/p/{código}` es la misma publicación que
  /// `instagram.com/p/{código}`.
  static void _instagram(_Parts parts) {
    parts.host = 'instagram.com';
    final List<String> segments = parts.segments;
    final int typeIndex = segments.indexWhere(
      (String s) => s == 'p' || s == 'reel' || s == 'reels' || s == 'tv',
    );

    if (typeIndex == -1 || typeIndex + 1 >= segments.length) {
      return;
    }
    // `reels` es la variante de la app; se unifica con `reel`.
    final String type = segments[typeIndex] == 'reels'
        ? 'reel'
        : segments[typeIndex];
    parts.segments = <String>[type, segments[typeIndex + 1]];
  }

  /// El slug del título no identifica: `/r/sub/comments/id/lo-que-sea` y
  /// `/r/sub/comments/id` son el mismo hilo.
  static void _reddit(_Parts parts) {
    parts.host = 'reddit.com';
    final int commentsIndex = parts.segments.indexOf('comments');
    if (commentsIndex != -1 && commentsIndex + 1 < parts.segments.length) {
      parts.segments = parts.segments.sublist(0, commentsIndex + 2);
    }
  }

  static void _cleanQuery(_Parts parts, LinkPlatform platform) {
    if (parts.query.isEmpty) {
      return;
    }

    // En YouTube ya sólo queda `v`, puesto ahí por _youtube.
    if (platform == LinkPlatform.youtube) {
      return;
    }

    // En las redes que identifican por ruta, cualquier parámetro sobra.
    if (_pathOnlyPlatforms.contains(platform)) {
      parts.query = <String, String>{};
      return;
    }

    // En la web genérica los parámetros pueden ser significativos
    // (`?page=2`), así que sólo se quita el seguimiento conocido.
    // Se ordenan para que el mismo enlace con los parámetros en distinto orden
    // dé la misma canónica.
    final List<String> kept =
        parts.query.keys.where((String k) => !_isTracking(k)).toList()..sort();

    parts.query = <String, String>{
      for (final String k in kept) k: parts.query[k]!,
    };
  }

  static bool _isTracking(String key) {
    final String lower = key.toLowerCase();
    return _trackingParams.contains(lower) || lower.startsWith('utm_');
  }
}
