import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/features/links/domain/link_query.dart' show CardSort;
import 'package:sambalinks/features/links/presentation/link_detail_pane.dart';
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

domain.LinkCard _card(int index) {
  return domain.LinkCard(
    id: 'card-$index',
    url: 'https://example.com/$index',
    canonicalUrl: 'https://example.com/$index',
    domain: 'example.com',
    title: 'Enlace $index',
    platform: LinkPlatform.web,
    status: CardStatus.pending,
    createdAt: DateTime.utc(2026, 8, 12).subtract(Duration(days: index)),
    updatedAt: DateTime.utc(2026, 8, 12).subtract(Duration(days: index)),
  );
}

Future<void> _pumpList(
  WidgetTester tester, {
  required List<domain.LinkCard> cards,
  Size size = const Size(1000, 900),
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
        linksProvider.overrideWith(
          (Ref ref, LinkQuery query) =>
              Stream<List<domain.LinkCard>>.value(cards),
        ),
        linkCountProvider.overrideWith(
          (Ref ref, LinkQuery query) => Stream<int>.value(cards.length),
        ),
        statusCountsProvider.overrideWith(
          (Ref ref) => Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
            CardStatus.pending: cards.length,
          }),
        ),
        scopedStatusCountsProvider.overrideWith(
          (Ref ref, LinkQuery query) => Stream<Map<CardStatus, int>>.value(
            <CardStatus, int>{CardStatus.pending: cards.length},
          ),
        ),
        categoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
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

/// Índice de la tarjeta que tiene el foco, o -1 si el foco está en otro sitio.
int _focusedCardIndex(WidgetTester tester) {
  final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) {
    return -1;
  }
  final Finder cards = find.byType(ui.LinkCard);
  for (int index = 0; index < cards.evaluate().length; index++) {
    final Finder match = find.descendant(
      of: cards.at(index),
      matching: find.byWidget(focused.widget),
    );
    if (match.evaluate().isNotEmpty) {
      return index;
    }
  }
  return -1;
}

void main() {
  testWidgets('las flechas recorren las tarjetas y Enter abre el detalle', (
    WidgetTester tester,
  ) async {
    await _pumpList(
      tester,
      cards: <domain.LinkCard>[for (int i = 0; i < 4; i++) _card(i)],
    );

    // El foco entra en la lista desde la barra superior con Tab.
    for (
      int attempt = 0;
      attempt < 12 && _focusedCardIndex(tester) < 0;
      attempt++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_focusedCardIndex(tester), 0, reason: 'Tab debe llegar a la lista');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_focusedCardIndex(tester), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_focusedCardIndex(tester), 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_focusedCardIndex(tester), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byType(LinkDetailPane), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tarjeta enfocada se distingue de las demás', (
    WidgetTester tester,
  ) async {
    await _pumpList(
      tester,
      cards: <domain.LinkCard>[for (int i = 0; i < 3; i++) _card(i)],
    );

    BorderSide sideOf(int index) {
      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ui.LinkCard).at(index),
              matching: find.byType(Material),
            )
            .first,
      );
      return (material.shape! as RoundedRectangleBorder).side;
    }

    expect(sideOf(0).width, 1);

    for (
      int attempt = 0;
      attempt < 12 && _focusedCardIndex(tester) < 0;
      attempt++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_focusedCardIndex(tester), 0);

    expect(sideOf(0).width, 2);
    expect(sideOf(0).color, isNot(sideOf(1).color));
  });

  testWidgets('la flecha abajo sigue avanzando más allá de lo visible', (
    WidgetTester tester,
  ) async {
    // La lista es virtualizada: las tarjetas que aún no se han construido no
    // están en el árbol de foco. Si el recorrido no arrastra el scroll consigo,
    // se queda clavado en el borde inferior de la ventana.
    await _pumpList(
      tester,
      cards: <domain.LinkCard>[for (int i = 0; i < 30; i++) _card(i)],
      size: const Size(900, 600),
    );

    for (
      int attempt = 0;
      attempt < 12 && _focusedCardIndex(tester) < 0;
      attempt++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_focusedCardIndex(tester), 0);

    final double before = tester
        .widget<Scrollable>(find.byType(Scrollable).last)
        .controller!
        .position
        .pixels;

    String? focusedTitle;
    for (int step = 0; step < 15; step++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final int index = _focusedCardIndex(tester);
      expect(
        index,
        isNonNegative,
        reason: 'el foco no puede salirse de la lista',
      );
      focusedTitle = tester
          .widget<ui.LinkCard>(find.byType(ui.LinkCard).at(index))
          .card
          .title;
    }

    expect(focusedTitle, 'Enlace 15');
    final double after = tester
        .widget<Scrollable>(find.byType(Scrollable).last)
        .controller!
        .position
        .pixels;
    expect(
      after,
      greaterThan(before),
      reason: 'la lista debe acompañar al foco',
    );
  });
}
