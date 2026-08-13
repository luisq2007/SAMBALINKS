import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/result.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/categories/domain/category_repository.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_query.dart';
import 'package:sambalinks/features/links/domain/link_repository.dart';
import 'package:sambalinks/features/links/presentation/link_detail_pane.dart';
import 'package:sambalinks/features/metadata/data/metadata_enrichment_service.dart';
import 'package:sambalinks/features/metadata/domain/metadata_image_store.dart';
import 'package:sambalinks/features/metadata/domain/metadata_provider.dart';

final DateTime _createdAt = DateTime.utc(2026, 8, 10, 9);

LinkCard _card({MetadataStatus metadataStatus = MetadataStatus.ok}) => LinkCard(
  id: 'card-1',
  url: 'https://example.com/original',
  canonicalUrl: 'https://example.com/original',
  domain: 'example.com',
  title: 'Título original',
  description: 'Descripción original',
  notes: 'Nota privada',
  status: CardStatus.active,
  metadataStatus: metadataStatus,
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

final Category _category = Category(
  id: 'ideas',
  name: 'Ideas',
  color: '#B9ECFA',
  createdAt: _createdAt,
  updatedAt: _createdAt,
);

class _FakeLinks implements LinkRepository {
  _FakeLinks(this.card);

  LinkCard? card;
  int updateCalls = 0;
  int deleteCalls = 0;
  int createCalls = 0;

  @override
  Future<Result<LinkCard>> create(LinkCard value) async {
    createCalls += 1;
    card = value;
    return Success<LinkCard>(value);
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls += 1;
    card = null;
  }

  @override
  Future<LinkCard?> findByCanonicalUrl(String canonicalUrl) async =>
      card?.canonicalUrl == canonicalUrl ? card : null;

  @override
  Future<LinkCard?> findById(String id) async => card?.id == id ? card : null;

  @override
  Future<Set<String>> getLocalImagePaths() async => const <String>{};

  @override
  Future<LinkCard> update(LinkCard value) async {
    updateCalls += 1;
    card = value.copyWith(
      updatedAt: DateTime.utc(2026, 8, 12, 12, updateCalls),
    );
    return card!;
  }

  @override
  Future<void> updateStatus(String id, CardStatus status) async {
    card = card?.copyWith(status: status);
  }

  @override
  Stream<int> watchCount([CardFilter filter = const CardFilter()]) =>
      Stream<int>.value(card == null ? 0 : 1);

  @override
  Stream<Map<CardStatus, int>> watchCountsByStatus([CardFilter filter = const CardFilter()]) =>
      Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
        for (final CardStatus value in CardStatus.values)
          value: card?.status == value ? 1 : 0,
      });

  @override
  Stream<List<LinkCard>> watchLinks({
    CardFilter filter = const CardFilter(),
    CardSort sort = CardSort.newest,
    int? limit,
    int offset = 0,
  }) => Stream<List<LinkCard>>.value(
    card == null ? const <LinkCard>[] : <LinkCard>[card!],
  );
}

class _FakeCategories implements CategoryRepository {
  _FakeCategories() : assigned = <String>{_category.id};

  Set<String> assigned;
  int restoreCalls = 0;

  @override
  Future<void> assign({
    required String cardId,
    required String categoryId,
  }) async {
    assigned.add(categoryId);
  }

  @override
  Future<Result<Category>> create({
    required String name,
    String? color,
    String? icon,
  }) async => Success<Category>(
    Category(
      id: name,
      name: name,
      color: color,
      icon: icon,
      createdAt: _createdAt,
      updatedAt: _createdAt,
    ),
  );

  @override
  Future<void> delete(String id) async {}

  @override
  Future<Category?> findById(String id) async =>
      id == _category.id ? _category : null;

  @override
  Future<void> reorder(List<String> orderedIds) async {}

  @override
  Future<void> setCategoriesOf(String cardId, Set<String> categoryIds) async {
    restoreCalls += 1;
    assigned = <String>{...categoryIds};
  }

  @override
  Future<void> unassign({
    required String cardId,
    required String categoryId,
  }) async {
    assigned.remove(categoryId);
  }

  @override
  Future<Category> update(Category category) async => category;

  @override
  Stream<List<Category>> watchAll() =>
      Stream<List<Category>>.value(<Category>[_category]);

  @override
  Stream<List<CategorySummary>> watchAllWithCounts() =>
      Stream<List<CategorySummary>>.value(<CategorySummary>[
        CategorySummary(category: _category, linkCount: 1),
      ]);

  @override
  Stream<List<Category>> watchCategoriesOf(String cardId) =>
      Stream<List<Category>>.value(
        assigned.contains(_category.id) ? <Category>[_category] : const [],
      );
}

class _RefreshMetadata implements MetadataProvider {
  @override
  Future<MetadataResult> fetch(Uri url) async => MetadataResult(
    title: 'Título actualizado',
    description: 'Descripción actualizada',
    imageUrl: 'https://cdn.example.com/preview.jpg',
    faviconUrl: 'https://example.com/favicon.ico',
    siteName: 'Sitio actualizado',
    status: MetadataStatus.ok,
  );
}

class _NoImages implements MetadataImageStore {
  @override
  Future<OrphanImageCleanupResult> cleanupOrphans(
    Set<String> referencedPaths, {
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async =>
      const OrphanImageCleanupResult(scanned: 0, deleted: 0, timedOut: false);

  @override
  Future<void> delete(String relativePath) async {}

  @override
  Future<String?> persist({
    required String cardId,
    required Uri imageUrl,
  }) async => null;
}

Finder _field(String label) => find.byWidgetPredicate(
  (Widget widget) =>
      widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _pumpDetail(
  WidgetTester tester, {
  required _FakeLinks links,
  required _FakeCategories categories,
  LinkCard? card,
}) async {
  final MetadataEnrichmentService metadata = MetadataEnrichmentService(
    links: links,
    metadata: _RefreshMetadata(),
    images: _NoImages(),
    now: () => DateTime.utc(2026, 8, 12, 14),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        linkRepositoryProvider.overrideWithValue(links),
        categoryRepositoryProvider.overrideWithValue(categories),
        metadataEnrichmentServiceProvider.overrideWithValue(metadata),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: LinkDetailPane(card: card ?? links.card!)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('autoguarda los tres campos tras exactamente 800 ms', (
    WidgetTester tester,
  ) async {
    final _FakeLinks links = _FakeLinks(_card());
    await _pumpDetail(tester, links: links, categories: _FakeCategories());

    await tester.enterText(_field('Título'), '  Título editado  ');
    await tester.pump(const Duration(milliseconds: 799));
    expect(links.updateCalls, 0);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(links.updateCalls, 1);
    expect(links.card?.title, 'Título editado');
    expect(links.card?.description, 'Descripción original');
    expect(links.card?.notes, 'Nota privada');
    expect(find.text('Cambios guardados'), findsOneWidget);
  });

  testWidgets('el menú contiene las once acciones del card', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      links: _FakeLinks(_card()),
      categories: _FakeCategories(),
    );

    await tester.tap(find.byTooltip('Más acciones del enlace'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.runtimeType.toString().startsWith('PopupMenuItem<'),
      ),
      findsNWidgets(11),
    );
    expect(find.text('Abrir original'), findsWidgets);
    expect(find.text('Copiar como Markdown'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
  });

  testWidgets(
    'actualizar vista previa preserva notas, estado, categoría y createdAt',
    (WidgetTester tester) async {
      final LinkCard original = _card();
      final _FakeLinks links = _FakeLinks(original);
      final _FakeCategories categories = _FakeCategories();
      await _pumpDetail(tester, links: links, categories: categories);

      await tester.tap(find.text('Actualizar vista previa'));
      await tester.pumpAndSettle();

      expect(links.card?.title, 'Título actualizado');
      expect(links.card?.description, 'Descripción actualizada');
      expect(links.card?.siteName, 'Sitio actualizado');
      expect(links.card?.notes, original.notes);
      expect(links.card?.status, original.status);
      expect(links.card?.createdAt, original.createdAt);
      expect(categories.assigned, <String>{_category.id});
      expect(find.text('Vista previa actualizada'), findsOneWidget);
    },
  );

  testWidgets('muestra un error de metadata comprensible y reintentable', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      links: _FakeLinks(_card(metadataStatus: MetadataStatus.failed)),
      categories: _FakeCategories(),
    );

    expect(
      find.text(
        'No pudimos actualizar la vista previa. El enlace sigue guardado.',
      ),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('deshacer restaura el card y sus categorías', (
    WidgetTester tester,
  ) async {
    final _FakeLinks links = _FakeLinks(_card());
    final _FakeCategories categories = _FakeCategories();
    await _pumpDetail(tester, links: links, categories: categories);

    await tester.tap(find.byTooltip('Más acciones del enlace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(links.deleteCalls, 1);
    expect(links.card, isNull);
    await tester.tap(find.text('Deshacer'));
    await tester.pump();

    expect(links.createCalls, 1);
    expect(links.card?.id, 'card-1');
    expect(categories.assigned, <String>{_category.id});
    expect(categories.restoreCalls, 1);
  });
}
