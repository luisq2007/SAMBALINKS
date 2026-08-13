import '../../links/domain/enums.dart';
import '../../links/domain/platform_detector.dart';
import '../domain/metadata_provider.dart';

class FallbackStrategy {
  const FallbackStrategy();

  MetadataResult fetch(Uri url) {
    final String domain = PlatformDetector.normalizeHost(url.host);
    final LinkPlatform platform = PlatformDetector.detect(domain);
    return MetadataResult(
      title: domain.isEmpty ? url.toString() : domain,
      siteName: _platformName(platform, domain),
      resolvedUrl: url,
      status: MetadataStatus.partial,
    );
  }

  static String _platformName(LinkPlatform platform, String domain) {
    return switch (platform) {
      LinkPlatform.instagram => 'Instagram',
      LinkPlatform.x => 'X',
      LinkPlatform.threads => 'Threads',
      LinkPlatform.pinterest => 'Pinterest',
      LinkPlatform.facebook => 'Facebook',
      LinkPlatform.tiktok => 'TikTok',
      LinkPlatform.youtube => 'YouTube',
      LinkPlatform.linkedin => 'LinkedIn',
      LinkPlatform.reddit => 'Reddit',
      LinkPlatform.web || LinkPlatform.other => domain,
    };
  }
}
