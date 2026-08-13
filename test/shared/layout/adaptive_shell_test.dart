import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/app.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_query.dart' show CardSort;
import 'package:sambalinks/shared/layout/breakpoints.dart';

SharedMediaFile _sharedText(String value) =>
    SharedMediaFile(path: value, type: SharedMediaType.text);

Category _category(String name, String color) => Category(
  id: name,
  name: name,
  color: color,
  createdAt: DateTime.utc(2026, 8, 12),
  updatedAt: DateTime.utc(2026, 8, 12),
);

Future<void> _pumpShell(
  WidgetTester tester, {
  required Size size,
  List<SharedMediaFile> initial = const <SharedMediaFile>[],
  List<LinkCard> cards = const <LinkCard>[],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  ReceiveSharingIntent.setMockValues(
    initialMedia: initial,
    mediaStream: const Stream<List<SharedMediaFile>>.empty(),
  );
  final List<CategorySummary> categories = <CategorySummary>[
    CategorySummary(
      category: _category('Leer después', '#B9ECFA'),
      linkCount: 3,
    ),
    CategorySummary(
      category: _category('Inspiración', '#B9F7D8'),
      linkCount: 2,
    ),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardSortPreferenceProvider.overrideWith(_FixedCardSortController.new),
        linksProvider.overrideWith(
          (Ref ref, LinkQuery query) => Stream.value(cards),
        ),
        linkCountProvider.overrideWith(
          (Ref ref, LinkQuery query) => Stream<int>.value(cards.length),
        ),
        seedProvider.overrideWith((Ref ref) async {}),
        orphanImageCleanupProvider.overrideWith((Ref ref) async {}),
        categoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(<Category>[
            for (final CategorySummary summary in categories) summary.category,
          ]),
        ),
        categoriesOfProvider.overrideWith(
          (Ref ref, String cardId) => Stream<List<Category>>.value(const []),
        ),
        categorySummariesProvider.overrideWith(
          (Ref ref) => Stream<List<CategorySummary>>.value(categories),
        ),
        statusCountsProvider.overrideWith(
          (Ref ref) =>
              Stream<Map<CardStatus, int>>.value(const <CardStatus, int>{
                CardStatus.pending: 3,
                CardStatus.active: 1,
                CardStatus.done: 1,
              }),
        ),
        inboxCountProvider.overrideWith((Ref ref) => Stream<int>.value(4)),
      ],
      child: const SambaLinksApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
}

class _FixedCardSortController extends CardSortController {
  @override
  Future<CardSort> build() async => CardSort.newest;

  @override
  Future<void> setSort(CardSort sort) async {
    state = AsyncData<CardSort>(sort);
  }
}

void main() {
  test('los cortes de ancho respetan el contrato de la fase 7', () {
    expect(SambaBreakpoints.fromWidth(599), SambaWindowClass.mobile);
    expect(SambaBreakpoints.fromWidth(600), SambaWindowClass.tablet);
    expect(SambaBreakpoints.fromWidth(1024), SambaWindowClass.tablet);
    expect(SambaBreakpoints.fromWidth(1025), SambaWindowClass.desktop);
    expect(SambaBreakpoints.fromWidth(1400), SambaWindowClass.desktop);
    expect(SambaBreakpoints.fromWidth(1401), SambaWindowClass.wideDesktop);
  });

  testWidgets('móvil usa navegación inferior, FAB y conserva la rama Inicio', (
    WidgetTester tester,
  ) async {
    await _pumpShell(
      tester,
      size: const Size(390, 844),
      initial: <SharedMediaFile>[
        _sharedText('Mira https://instagram.com/p/estado-persistente/'),
      ],
    );

    expect(find.byKey(const ValueKey<String>('mobile-shell')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(
      find.text('https://instagram.com/p/estado-persistente'),
      findsOneWidget,
    );

    await tester.tap(find.text('Kanban').last);
    await tester.pump();
    expect(find.text('Organiza tu flujo'), findsOneWidget);

    await tester.tap(find.text('Inicio').last);
    await tester.pump();
    expect(
      find.text('https://instagram.com/p/estado-persistente'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet usa NavigationRail y rota sin overflow', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, size: const Size(800, 900));

    expect(find.byKey(const ValueKey<String>('tablet-shell')), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('escritorio permite colapsar el sidebar con contadores vivos', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, size: const Size(1200, 800));

    expect(find.byKey(const ValueKey<String>('desktop-shell')), findsOneWidget);
    final Finder sidebar = find.byKey(
      const ValueKey<String>('desktop-sidebar'),
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('Leer después')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('Inspiración')),
      findsOneWidget,
    );
    expect(find.text('4'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('collapse-sidebar')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey<String>('expand-sidebar')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('Leer después')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('escritorio ancho añade una tercera columna de detalle', (
    WidgetTester tester,
  ) async {
    final LinkCard card = LinkCard(
      id: 'wide-card',
      url: 'https://example.com/wide',
      canonicalUrl: 'https://example.com/wide',
      domain: 'example.com',
      title: 'Detalle seleccionado',
      createdAt: DateTime.utc(2026, 8, 12),
      updatedAt: DateTime.utc(2026, 8, 12),
    );
    await _pumpShell(
      tester,
      size: const Size(1500, 900),
      cards: <LinkCard>[card],
    );

    expect(
      find.byKey(const ValueKey<String>('wide-desktop-shell')),
      findsOneWidget,
    );
    expect(find.text('Detalle del enlace'), findsOneWidget);

    await tester.tap(find.text('Detalle seleccionado').first);
    await tester.pump();

    expect(find.text('Detalle del enlace'), findsNothing);
    expect(find.text('Detalle seleccionado'), findsNWidgets(3));
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('redimensionar de 400 a 1600 conserva el contenido de Inicio', (
    WidgetTester tester,
  ) async {
    await _pumpShell(
      tester,
      size: const Size(400, 800),
      initial: <SharedMediaFile>[_sharedText('https://x.com/samba/status/7')],
    );
    expect(find.text('https://x.com/samba/status/7'), findsOneWidget);

    for (final double width in <double>[800, 1200, 1600]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('https://x.com/samba/status/7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
