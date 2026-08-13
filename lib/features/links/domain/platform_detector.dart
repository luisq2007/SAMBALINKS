import 'enums.dart';

/// Deduce la plataforma de origen a partir del anfitrión de la URL.
abstract final class PlatformDetector {
  /// Anfitriones exactos, ya sin `www.` ni subdominios móviles.
  static const Map<String, LinkPlatform> _byHost = <String, LinkPlatform>{
    'instagram.com': LinkPlatform.instagram,
    'instagr.am': LinkPlatform.instagram,
    'x.com': LinkPlatform.x,
    'twitter.com': LinkPlatform.x,
    't.co': LinkPlatform.x,
    'threads.com': LinkPlatform.threads,
    'threads.net': LinkPlatform.threads,
    'pinterest.com': LinkPlatform.pinterest,
    'pin.it': LinkPlatform.pinterest,
    'facebook.com': LinkPlatform.facebook,
    'fb.com': LinkPlatform.facebook,
    'fb.me': LinkPlatform.facebook,
    'fb.watch': LinkPlatform.facebook,
    'tiktok.com': LinkPlatform.tiktok,
    'vm.tiktok.com': LinkPlatform.tiktok,
    'vt.tiktok.com': LinkPlatform.tiktok,
    'youtube.com': LinkPlatform.youtube,
    'youtu.be': LinkPlatform.youtube,
    'linkedin.com': LinkPlatform.linkedin,
    'lnkd.in': LinkPlatform.linkedin,
    'reddit.com': LinkPlatform.reddit,
    'redd.it': LinkPlatform.reddit,
  };

  /// Pinterest y Facebook usan dominios por país (`pinterest.es`,
  /// `facebook.com.mx`), así que no basta con la tabla de anfitriones exactos.
  static const Map<String, LinkPlatform> _byPrefix = <String, LinkPlatform>{
    'pinterest.': LinkPlatform.pinterest,
    'facebook.': LinkPlatform.facebook,
  };

  static LinkPlatform detect(String host) {
    final String normalized = normalizeHost(host);
    if (normalized.isEmpty) {
      return LinkPlatform.other;
    }

    final LinkPlatform? exact = _byHost[normalized];
    if (exact != null) {
      return exact;
    }

    for (final MapEntry<String, LinkPlatform> entry in _byPrefix.entries) {
      if (normalized.startsWith(entry.key)) {
        return entry.value;
      }
    }

    // Los subdominios de una plataforma conocida cuentan como esa plataforma:
    // p. ej. `es.linkedin.com` o `old.reddit.com`.
    for (final MapEntry<String, LinkPlatform> entry in _byHost.entries) {
      if (normalized.endsWith('.${entry.key}')) {
        return entry.value;
      }
    }

    return LinkPlatform.web;
  }

  /// Quita `www.` y los prefijos de versión móvil.
  ///
  /// `vm.tiktok.com` y `vt.tiktok.com` se dejan intactos: no son versiones
  /// móviles sino acortadores, y confundirlos rompería su resolución.
  static String normalizeHost(String host) {
    String result = host.toLowerCase().trim();
    if (result.startsWith('vm.tiktok.com') ||
        result.startsWith('vt.tiktok.com')) {
      return result;
    }
    for (final String prefix in <String>['www.', 'm.', 'mobile.', 'web.']) {
      if (result.startsWith(prefix)) {
        result = result.substring(prefix.length);
        break;
      }
    }
    return result;
  }
}
