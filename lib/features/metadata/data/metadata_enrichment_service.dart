import '../../links/domain/link_card.dart';
import '../../links/domain/link_repository.dart';
import '../../links/domain/url_normalizer.dart';
import '../domain/metadata_image_store.dart';
import '../domain/metadata_provider.dart';
import '../domain/metadata_refresh_outcome.dart';

class MetadataEnrichmentService {
  MetadataEnrichmentService({
    required LinkRepository links,
    required MetadataProvider metadata,
    required MetadataImageStore images,
    DateTime Function()? now,
  }) : _links = links,
       _metadata = metadata,
       _images = images,
       _now = now ?? (() => DateTime.now().toUtc());

  final LinkRepository _links;
  final MetadataProvider _metadata;
  final MetadataImageStore _images;
  final DateTime Function() _now;

  Future<MetadataRefreshOutcome> refreshCard(String cardId) async {
    final LinkCard? current = await _links.findById(cardId);
    if (current == null) {
      return MetadataRefreshCardNotFound(cardId);
    }

    final Uri url = Uri.tryParse(current.url) ?? Uri(path: current.url);
    final MetadataResult metadata = await _metadata.fetch(url);
    final NormalizedUrl? resolved = metadata.resolvedUrl == null
        ? null
        : UrlNormalizer.normalize(metadata.resolvedUrl.toString());

    LinkCard? duplicate;
    if (resolved != null && resolved.canonical != current.canonicalUrl) {
      final LinkCard? candidate = await _links.findByCanonicalUrl(
        resolved.canonical,
      );
      if (candidate != null && candidate.id != current.id) {
        duplicate = candidate;
      }
    }

    String? localImage = current.localImage;
    final Uri? imageUri = Uri.tryParse(metadata.imageUrl ?? '');
    if (imageUri != null &&
        (imageUri.scheme == 'http' || imageUri.scheme == 'https')) {
      localImage =
          await _images.persist(cardId: current.id, imageUrl: imageUri) ??
          localImage;
    }

    final LinkCard next = current.copyWith(
      canonicalUrl: duplicate == null && resolved != null
          ? resolved.canonical
          : current.canonicalUrl,
      domain: resolved?.domain ?? current.domain,
      platform: resolved?.platform ?? current.platform,
      title: metadata.title ?? current.title,
      description: metadata.description ?? current.description,
      imageUrl: metadata.imageUrl ?? current.imageUrl,
      localImage: localImage,
      faviconUrl: metadata.faviconUrl ?? current.faviconUrl,
      siteName: metadata.siteName ?? current.siteName,
      metadataFetchedAt: _now(),
      metadataStatus: metadata.status,
    );
    final LinkCard stored = await _links.update(next);

    if (duplicate != null && resolved != null) {
      return MetadataRefreshDuplicate(
        card: stored,
        existingCardId: duplicate.id,
        resolvedCanonicalUrl: resolved.canonical,
      );
    }
    return MetadataRefreshUpdated(stored);
  }

  Future<OrphanImageCleanupResult> cleanupOrphanedImages({
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async {
    final Set<String> referenced = await _links.getLocalImagePaths();
    return _images.cleanupOrphans(referenced, timeLimit: timeLimit);
  }
}
