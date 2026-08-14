import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/result.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/categories/domain/category_repository.dart';
import 'package:sambalinks/features/links/data/link_saver.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_repository.dart';
import 'package:sambalinks/features/links/domain/url_normalizer.dart';
import 'package:sambalinks/features/metadata/data/metadata_enrichment_service.dart';
import 'package:sambalinks/features/metadata/domain/metadata_image_store.dart';
import 'package:sambalinks/features/metadata/domain/metadata_refresh_outcome.dart';
import 'package:sambalinks/features/sharing/domain/incoming_share.dart';
import 'package:sambalinks/features/sharing/presentation/quick_save_sheet.dart';

import '../../core/database/database_test_helpers.dart';

class _RecordingEnrichment implements MetadataEnrichmentService {
  final List<String> refreshed = <String>[];

  @override
  Future<MetadataRefreshOutcome> refreshCard(String cardId) async {
    refreshed.add(cardId);
    return MetadataRefreshCardNotFound(cardId);
  }

  @override
  Future<OrphanImageCleanupResult> cleanupOrphanedImages({
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async =>
      const OrphanImageCleanupResult(scanned: 0, deleted: 0, timedOut: false);
}

IncomingShare _share(String text) {
  final String? url = RegExp(r'https?://\S+').firstMatch(text)?.group(0);
  return IncomingShare(
    rawText: text,
    url: url,
    normalized: url == null ? null : UrlNormalizer.normalize(url),
    arrival: ShareArrival.cold,
    receivedAt: DateTime.utc(2026, 8, 13),
  );
}

void main() {
  late AppDatabase db;
  late _RecordingEnrichment enrichment;
  late LinkSaver saver;

  setUp(() {
    db = openTestDatabase();
    enrichment = _RecordingEnrichment();
  });
  tearDown(() => db.close());

  group('LinkSaver', () {
    setUp(() {
      saver = LinkSaver(
        links: DriftHelpers.linkRepository(db),
        categories: DriftHelpers.categoryRepository(db),
        enrichment: enrichment,
      );
    });

    test('normaliza, guarda y pide la metadata sin bloquear', () async {
      final Result<LinkCard> result = await saver.save(
        rawUrl: 'https://www.instagram.com/usuario/p/ABC/?igshid=x',
      );

      final LinkCard card = result.valueOrNull!;
      expect(card.canonicalUrl, 'https://instagram.com/p/ABC');
      expect(card.platform, LinkPlatform.instagram);
      // Capture first: se pidió la metadata, pero el enlace ya estaba guardado.
      expect(enrichment.refreshed, <String>[card.id]);
    });

    test('nace en Pendiente y sin categoría, o sea, en la Bandeja', () async {
      final LinkCard card = (await saver.save(
        rawUrl: 'https://ejemplo.com/a',
      )).valueOrNull!;

      expect(card.status, CardStatus.pending);
      final CategoryRepository categories = DriftHelpers.categoryRepository(db);
      expect(await categories.watchCategoriesOf(card.id).first, isEmpty);
    });

    test('conserva el texto íntegro que envió la otra app', () async {
      const String shared = 'Mira esto https://ejemplo.com/a que está genial';
      final LinkCard card = (await saver.save(
        rawUrl: 'https://ejemplo.com/a',
        originalSharedText: shared,
      )).valueOrNull!;

      expect(card.originalSharedText, shared);
    });

    test('aplica estado, nota y categorías cuando se indican', () async {
      final CategoryRepository categories = DriftHelpers.categoryRepository(db);
      final Category ideas = (await categories.create(
        name: 'Ideas',
      )).valueOrNull!;

      final LinkCard card = (await saver.save(
        rawUrl: 'https://ejemplo.com/b',
        status: CardStatus.active,
        note: '  una nota  ',
        categoryIds: <String>{ideas.id},
      )).valueOrNull!;

      expect(card.status, CardStatus.active);
      expect(card.notes, 'una nota');
      final List<Category> assigned = await categories
          .watchCategoriesOf(card.id)
          .first;
      expect(assigned.single.name, 'Ideas');
    });

    test('una nota en blanco no se guarda como cadena vacía', () async {
      final LinkCard card = (await saver.save(
        rawUrl: 'https://ejemplo.com/c',
        note: '   ',
      )).valueOrNull!;

      expect(card.notes, isNull);
    });

    test('rechaza lo que no es una URL', () async {
      final Result<LinkCard> result = await saver.save(rawUrl: 'no soy un url');

      expect(result.failureOrNull, isA<InvalidUrlFailure>());
      expect(enrichment.refreshed, isEmpty);
    });

    test('un duplicado no crea una copia y señala el existente', () async {
      final LinkCard first = (await saver.save(
        rawUrl: 'https://instagram.com/p/ABC',
      )).valueOrNull!;

      final Result<LinkCard> second = await saver.save(
        rawUrl: 'https://www.instagram.com/otro/p/ABC/?igshid=y',
      );

      expect(
        (second.failureOrNull! as DuplicateLinkFailure).existingCardId,
        first.id,
      );
      final LinkRepository links = DriftHelpers.linkRepository(db);
      expect(await links.watchCount().first, 1);
    });
  });

  group('Quick Save', () {
    Future<ProviderContainer> pumpSheet(
      WidgetTester tester,
      IncomingShare share,
    ) async {
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            metadataEnrichmentServiceProvider.overrideWithValue(enrichment),
            // Sin streams de Drift vivos: dejan un timer pendiente que hace
            // fallar la comprobación de invariantes de flutter_test.
            categoriesProvider.overrideWith(
              (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: const Locale('es'),
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => QuickSaveSheet.show(context, share),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      container = ProviderScope.containerOf(
        tester.element(find.text('abrir')),
        listen: false,
      );
      await tester.tap(find.text('abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return container;
    }

    testWidgets('compartir y guardar sin tocar ningún campo', (
      WidgetTester tester,
    ) async {
      // El flujo mínimo del PRD (§7): ningún campo es obligatorio.
      final ProviderContainer container = await pumpSheet(
        tester,
        _share('Mira esto https://www.tiktok.com/@user/video/123'),
      );

      await tester.tap(find.text('Guardar'));
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }

      final LinkCard? saved = await container
          .read(linkRepositoryProvider)
          .findByCanonicalUrl('https://tiktok.com/@user/video/123');
      expect(saved, isNotNull);
      expect(saved!.status, CardStatus.pending);
    });

    testWidgets('muestra la URL canónica, no la que llegó', (
      WidgetTester tester,
    ) async {
      await pumpSheet(
        tester,
        _share('https://www.instagram.com/usuario/p/ABC/?igshid=x'),
      );

      expect(find.text('https://instagram.com/p/ABC'), findsOneWidget);
    });

    testWidgets('avisa si el enlace ya estaba guardado', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpSheet(
        tester,
        _share('https://instagram.com/p/DUP'),
      );
      await container.read(linkSaverProvider).save(
        rawUrl: 'https://instagram.com/p/DUP',
      );

      await tester.tap(find.text('Guardar'));
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }

      expect(find.text('Este enlace ya está en SambaLinks'), findsOneWidget);
    });
  });
}
