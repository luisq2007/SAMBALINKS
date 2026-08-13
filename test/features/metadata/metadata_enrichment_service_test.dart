import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/features/links/data/drift_link_repository.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/metadata/data/metadata_enrichment_service.dart';
import 'package:sambalinks/features/metadata/domain/metadata_image_store.dart';
import 'package:sambalinks/features/metadata/domain/metadata_provider.dart';
import 'package:sambalinks/features/metadata/domain/metadata_refresh_outcome.dart';

import '../../core/database/database_test_helpers.dart';

class _FixedMetadataProvider implements MetadataProvider {
  _FixedMetadataProvider(this.result);

  final MetadataResult result;

  @override
  Future<MetadataResult> fetch(Uri url) async => result;
}

class _MemoryImageStore implements MetadataImageStore {
  String? persistedPath;
  Set<String>? cleanupReferences;

  @override
  Future<String?> persist({
    required String cardId,
    required Uri imageUrl,
  }) async {
    persistedPath = 'images/$cardId.jpg';
    return persistedPath;
  }

  @override
  Future<void> delete(String relativePath) async {}

  @override
  Future<OrphanImageCleanupResult> cleanupOrphans(
    Set<String> referencedPaths, {
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async {
    cleanupReferences = referencedPaths;
    return const OrphanImageCleanupResult(
      scanned: 0,
      deleted: 0,
      timedOut: false,
    );
  }
}

LinkCard _card({
  required String id,
  required String url,
  required String canonical,
  String? localImage,
}) {
  final DateTime created = DateTime.utc(2026, 8, 12, 12);
  return LinkCard(
    id: id,
    url: url,
    canonicalUrl: canonical,
    domain: Uri.parse(canonical).host,
    notes: 'nota intacta',
    status: CardStatus.active,
    localImage: localImage,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  late AppDatabase db;
  late DriftLinkRepository links;

  setUp(() {
    db = openTestDatabase();
    links = DriftLinkRepository(db, now: () => DateTime.utc(2026, 8, 12, 13));
  });
  tearDown(() => db.close());

  test('actualiza metadata, canónica resuelta e imagen local', () async {
    final LinkCard original = _card(
      id: 'short',
      url: 'https://bit.ly/abc',
      canonical: 'https://bit.ly/abc',
    );
    await links.create(original);
    final _MemoryImageStore images = _MemoryImageStore();
    final MetadataEnrichmentService service = MetadataEnrichmentService(
      links: links,
      metadata: _FixedMetadataProvider(
        MetadataResult(
          title: 'Artículo final',
          description: 'Descripción',
          imageUrl: 'https://cdn.example/preview.jpg',
          faviconUrl: 'https://example.com/favicon.ico',
          siteName: 'Ejemplo',
          resolvedUrl: Uri.parse('https://example.com/article?utm_source=x'),
          status: MetadataStatus.ok,
        ),
      ),
      images: images,
      now: () => DateTime.utc(2026, 8, 12, 12, 30),
    );

    final MetadataRefreshOutcome outcome = await service.refreshCard('short');
    final LinkCard stored = (outcome as MetadataRefreshUpdated).card;

    expect(stored.canonicalUrl, 'https://example.com/article');
    expect(stored.domain, 'example.com');
    expect(stored.title, 'Artículo final');
    expect(stored.localImage, 'images/short.jpg');
    expect(stored.metadataStatus, MetadataStatus.ok);
    expect(
      stored.metadataFetchedAt?.toUtc(),
      DateTime.utc(2026, 8, 12, 12, 30),
    );
    expect(stored.notes, original.notes);
    expect(stored.status, original.status);
    expect(stored.createdAt.toUtc(), original.createdAt);
    expect(stored.updatedAt.toUtc(), DateTime.utc(2026, 8, 12, 13));
  });

  test('detecta duplicado tras redirect sin fusionar ni borrar', () async {
    await links.create(
      _card(
        id: 'existente',
        url: 'https://example.com/final',
        canonical: 'https://example.com/final',
      ),
    );
    await links.create(
      _card(
        id: 'corto',
        url: 'https://bit.ly/xyz',
        canonical: 'https://bit.ly/xyz',
      ),
    );
    final MetadataEnrichmentService service = MetadataEnrichmentService(
      links: links,
      metadata: _FixedMetadataProvider(
        MetadataResult(
          title: 'Resultado',
          resolvedUrl: Uri.parse('https://example.com/final?utm_medium=share'),
          status: MetadataStatus.partial,
        ),
      ),
      images: _MemoryImageStore(),
    );

    final MetadataRefreshOutcome outcome = await service.refreshCard('corto');

    expect(outcome, isA<MetadataRefreshDuplicate>());
    final MetadataRefreshDuplicate duplicate =
        outcome as MetadataRefreshDuplicate;
    expect(duplicate.existingCardId, 'existente');
    expect(duplicate.resolvedCanonicalUrl, 'https://example.com/final');
    expect(duplicate.card.canonicalUrl, 'https://bit.ly/xyz');
    expect(duplicate.card.title, 'Resultado');
    expect(await links.findById('existente'), isNotNull);
    expect(await links.findById('corto'), isNotNull);
  });

  test('la limpieza recibe únicamente imágenes referenciadas', () async {
    await links.create(
      _card(
        id: 'a',
        url: 'https://a.example',
        canonical: 'https://a.example',
        localImage: 'images/a.jpg',
      ),
    );
    await links.create(
      _card(id: 'b', url: 'https://b.example', canonical: 'https://b.example'),
    );
    final _MemoryImageStore images = _MemoryImageStore();
    final MetadataEnrichmentService service = MetadataEnrichmentService(
      links: links,
      metadata: _FixedMetadataProvider(
        const MetadataResult(status: MetadataStatus.partial),
      ),
      images: images,
    );

    await service.cleanupOrphanedImages();

    expect(images.cleanupReferences, <String>{'images/a.jpg'});
  });

  test(
    'devuelve not found si la tarjeta desapareció antes del turno',
    () async {
      final MetadataEnrichmentService service = MetadataEnrichmentService(
        links: links,
        metadata: _FixedMetadataProvider(
          const MetadataResult(status: MetadataStatus.partial),
        ),
        images: _MemoryImageStore(),
      );

      final MetadataRefreshOutcome outcome = await service.refreshCard(
        'no-existe',
      );

      expect(outcome, isA<MetadataRefreshCardNotFound>());
    },
  );
}
