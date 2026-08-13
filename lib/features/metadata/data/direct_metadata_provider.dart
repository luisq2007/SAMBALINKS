import '../../../core/network/http_client.dart';
import '../../links/domain/enums.dart';
import '../../links/domain/url_normalizer.dart';
import '../domain/metadata_provider.dart';
import 'fallback_strategy.dart';
import 'html_meta_strategy.dart';
import 'oembed_strategy.dart';

typedef UrlResolver = Future<Uri> Function(Uri url);

class DirectMetadataProvider implements MetadataProvider {
  DirectMetadataProvider({
    required OEmbedStrategy oEmbed,
    required HtmlMetaStrategy html,
    required SafeHttpClient httpClient,
    UrlResolver? resolveUrl,
    FallbackStrategy fallback = const FallbackStrategy(),
  }) : _oEmbed = oEmbed,
       _html = html,
       _resolveUrl = resolveUrl ?? httpClient.resolve,
       _fallback = fallback;

  final OEmbedStrategy _oEmbed;
  final HtmlMetaStrategy _html;
  final UrlResolver _resolveUrl;
  final FallbackStrategy _fallback;

  @override
  Future<MetadataResult> fetch(Uri url) async {
    if ((url.scheme != 'http' && url.scheme != 'https') || url.host.isEmpty) {
      return MetadataResult(
        resolvedUrl: url,
        status: MetadataStatus.unsupported,
      );
    }

    Uri effectiveUrl = url;
    final NormalizedUrl? normalized = UrlNormalizer.normalize(url.toString());
    if (normalized?.needsNetworkResolution ?? false) {
      try {
        effectiveUrl = await _resolveUrl(url);
      } on Object {
        // Resolver el acortador ayuda a deduplicar, pero su fallo nunca puede
        // impedir que el enlace quede representado por el fallback.
      }
    }

    try {
      final MetadataResult? oEmbed = await _oEmbed.fetch(effectiveUrl);
      if (oEmbed?.hasUsefulContent ?? false) {
        return oEmbed!;
      }
    } on Object {
      // La siguiente estrategia sigue disponible.
    }

    try {
      final MetadataResult? html = await _html.fetch(effectiveUrl);
      if (html?.hasUsefulContent ?? false) {
        return html!;
      }
    } on Object {
      // El fallback es parte del contrato, no una pantalla de error.
    }

    return _fallback.fetch(effectiveUrl);
  }
}
