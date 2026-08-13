import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/features/links/domain/link_query.dart'
    show CardFilter, CardSort;
import 'package:sambalinks/features/links/presentation/link_detail_pane.dart';
import 'package:sambalinks/features/links/presentation/link_list_filters.dart';
import 'package:sambalinks/features/links/presentation/links_list_screen.dart';
import 'package:sambalinks/shared/widgets/link_card.dart' as ui;

class _FixedCardSortController extends CardSortController {
  @override
  Future<CardSort> build() async => CardSort.newest;

  @override
  Future<void> setSort(CardSort sort) async {
    state = AsyncData<CardSort>(sort);
  }
}

domain.LinkCard _card(
  int index, {
  CardStatus status = CardStatus.pending,
  LinkPlatform platform = LinkPlatform.web,
  bool withNotes = false,
}) {
  final String id = 'card-$index';
  return domain.LinkCard(
    id: id,
    url: 'https://example.com/$index',
    canonicalUrl: 'https://example.com/$index',
    domain: 'example.com',
    title: 'Enlace $index',
    description: 'Descripción del enlace $index',
    notes: withNotes ? 'Nota $index' : null,
    platform: platform,
    status: status,
    createdAt: DateTime.utc(2026, 8, 12).subtract(Duration(days: index)),
    updatedAt: DateTime.utc(2026, 8, 12).subtract(Duration(days: index)),
  );
}

List<domain.LinkCard> _applyQuery(
  List<domain.LinkCard> source,
  LinkQuery query,
) {
  Iterable<domain.LinkCard> result = source;
  final CardFilter filter = query.filter;
  if (filter.statuses case final Set<CardStatus> statuses
      when statuses.isNotEmpty) {
    result = result.where(
      (domain.LinkCard card) => statuses.contains(card.status),
    );
  }
  if (filter.platforms case final Set<LinkPlatform> platforms
      when platforms.isNotEmpty) {
    result = result.where(
      (domain.LinkCard card) => platforms.contains(card.platform),
    );
  }
  final String search = filter.query?.toLowerCase().trim() ?? '';
  if (search.isNotEmpty) {
    result = result.where(
      (domain.LinkCard card) =>
          card.displayTitle.toLowerCase().contains(search),
    );
  }
  final List<domain.LinkCard> filtered = result.toList();
  if (query.sort == CardSort.oldest) {
    filtered.sort(
      (domain.LinkCard a, domain.LinkCard b) =>
          a.createdAt.compareTo(b.createdAt),
    );
  }
  return filtered
      .skip(query.offset)
      .take(query.limit ?? filtered.length)
      .toList();
}

int _count(List<domain.LinkCard> source, CardFilter filter) =>
    _applyQuery(source, LinkQuery(filter: filter)).length;

Future<void> _pumpList(
  WidgetTester tester, {
  required List<domain.LinkCard> cards,
  required List<LinkQuery> queries,
  List<Category> categories = const <Category>[],
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  ReceiveSharingIntent.setMockValues(
    initialMedia: const [],
    mediaStream: const Stream.empty(),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardSortPreferenceProvider.overrideWith(_FixedCardSortController.new),
        linksProvider.overrideWith((Ref ref, LinkQuery query) {
          queries.add(query);
          return Stream<List<domain.LinkCard>>.value(_applyQuery(cards, query));
        }),
        linkCountProvider.overrideWith(
          (Ref ref, LinkQuery query) =>
              Stream<int>.value(_count(cards, query.filter)),
        ),
        statusCountsProvider.overrideWith(
          (Ref ref) => Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
            for (final CardStatus status in CardStatus.values)
              status: cards
                  .where((domain.LinkCard c) => c.status == status)
                  .length,
          }),
        ),
        categoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
        categoriesOfProvider.overrideWith(
          (Ref ref, String id) =>
              Stream<List<Category>>.value(const <Category>[]),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        theme: AppTheme.light,
        home: const Scaffold(body: LinksListScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
}

void main() {
  group('Vista Lista', () {
    testWidgets('abre el detalle expandible al tocar un card en móvil', (
      WidgetTester tester,
    ) async {
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[_card(1)],
        queries: <LinkQuery>[],
      );

      await tester.tap(find.byType(ui.LinkCard));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(LinkDetailPane), findsOneWidget);
      expect(find.text('Título'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('consulta sólo la primera página de 40 al iniciar', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[
          for (int index = 0; index < 55; index++) _card(index),
        ],
        queries: queries,
      );

      expect(
        queries,
        contains(
          isA<LinkQuery>()
              .having((LinkQuery q) => q.limit, 'limit', 40)
              .having((LinkQuery q) => q.offset, 'offset', 0),
        ),
      );
      expect(find.text('55 enlaces'), findsOneWidget);
    });

    testWidgets('carga la segunda página al acercarse al final', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[
          for (int index = 0; index < 55; index++) _card(index),
        ],
        queries: queries,
        size: const Size(800, 900),
      );

      for (int attempt = 0; attempt < 20; attempt++) {
        await tester.drag(find.byType(ListView).last, const Offset(0, -700));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        queries.any((LinkQuery q) => q.limit == 40 && q.offset == 40),
        isTrue,
      );
    });

    testWidgets('la búsqueda espera exactamente el debounce de 250 ms', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[_card(1), _card(2)],
        queries: queries,
      );
      queries.clear();

      await tester.enterText(find.byType(TextField), 'Enlace 2');
      await tester.pump(const Duration(milliseconds: 249));
      expect(
        queries.where((LinkQuery q) => q.filter.query == 'Enlace 2'),
        isEmpty,
      );

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(
        queries.any((LinkQuery q) => q.filter.query == 'Enlace 2'),
        isTrue,
      );
      expect(
        find.descendant(
          of: find.byType(ui.LinkCard),
          matching: find.text('Enlace 2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ui.LinkCard),
          matching: find.text('Enlace 1'),
        ),
        findsNothing,
      );
    });

    testWidgets('las pestañas por estado cambian la consulta', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[
          _card(1),
          _card(2, status: CardStatus.done),
        ],
        queries: queries,
      );

      final Finder done = find.widgetWithText(ChoiceChip, 'Atendido · 1');
      await tester.ensureVisible(done);
      await tester.pump();
      await tester.tap(done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        queries.any(
          (LinkQuery q) =>
              q.filter.statuses?.contains(CardStatus.done) ?? false,
        ),
        isTrue,
      );
      expect(find.text('Enlace 2'), findsOneWidget);
      expect(find.text('Enlace 1'), findsNothing);
    });

    testWidgets('el panel aplica filtros combinados', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[_card(1, platform: LinkPlatform.instagram)],
        queries: queries,
        categories: <Category>[
          for (int index = 0; index < 3; index++)
            Category(
              id: 'category-$index',
              name: 'Categoría $index',
              createdAt: DateTime.utc(2026, 8, 12),
              updatedAt: DateTime.utc(2026, 8, 12),
            ),
        ],
        size: const Size(390, 640),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Instagram'));
      final Finder withNotes = find.widgetWithText(ChoiceChip, 'Con notas');
      await tester.ensureVisible(withNotes);
      await tester.pump();
      await tester.tap(withNotes);
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      expect(
        queries.any(
          (LinkQuery q) =>
              (q.filter.platforms?.contains(LinkPlatform.instagram) ?? false) &&
              q.filter.hasNotes == true,
        ),
        isTrue,
      );
      expect(find.text('2 filtros activos'), findsOneWidget);
    });

    testWidgets('persistir otra ordenación actualiza la consulta', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(
        tester,
        cards: <domain.LinkCard>[_card(1), _card(2)],
        queries: queries,
      );

      await tester.tap(find.byTooltip('Cambiar orden'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<CardSort>, 'Más antiguos'),
      );
      await tester.pump();

      expect(queries.any((LinkQuery q) => q.sort == CardSort.oldest), isTrue);
    });

    testWidgets('diferencia biblioteca, búsqueda y filtros sin resultados', (
      WidgetTester tester,
    ) async {
      final List<LinkQuery> queries = <LinkQuery>[];
      await _pumpList(tester, cards: const [], queries: queries);
      expect(find.text('Tu biblioteca está vacía'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'imposible');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('No encontramos “imposible”'), findsOneWidget);

      await tester.tap(find.byTooltip('Limpiar filtros'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Instagram'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(
        find.text('Ningún enlace coincide con estos filtros'),
        findsOneWidget,
      );
    });
  });

  group('LinkCard', () {
    for (final ui.LinkCardDensity density in ui.LinkCardDensity.values) {
      testWidgets('${density.name} renderiza sin overflow', (
        WidgetTester tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = density == ui.LinkCardDensity.mobile
            ? const Size(390, 844)
            : const Size(1000, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: ui.LinkCard(card: _card(1), density: density),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Enlace 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('LinkListFilters', () {
    test('cuenta grupos activos y traduce la fecha a un rango UTC', () {
      const LinkListFilters filters = LinkListFilters(
        statuses: <CardStatus>{CardStatus.active},
        platforms: <LinkPlatform>{LinkPlatform.youtube},
        date: LinkDateFilter.last7Days,
        hasImage: true,
        uncategorized: true,
      );

      expect(filters.activeCount, 5);
      final CardFilter result = filters.toCardFilter(
        now: DateTime(2026, 8, 12, 22),
      );
      expect(result.createdAfter, DateTime.utc(2026, 8, 6, 5));
      expect(result.hasImage, isTrue);
      expect(result.uncategorized, isTrue);
    });
  });
}
