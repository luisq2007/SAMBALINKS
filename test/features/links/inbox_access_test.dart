import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/routing/routes.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/features/links/domain/link_query.dart' show CardSort;
import 'package:sambalinks/features/links/presentation/link_list_filters.dart';
import 'package:sambalinks/features/links/presentation/links_list_screen.dart';

class _FixedCardSortController extends CardSortController {
  @override
  Future<CardSort> build() async => CardSort.newest;

  @override
  Future<void> setSort(CardSort sort) async {
    state = AsyncData<CardSort>(sort);
  }
}

/// La Bandeja es el centro del flujo del PRD (§16) y hasta la F10 sólo se
/// alcanzaba desde la barra lateral de escritorio: en móvil era invisible.
///
/// Sin base de datos real: los streams de Drift no resuelven dentro del reloj
/// simulado de `testWidgets` y dejan el test colgado.
void main() {
  Future<void> pumpList(
    WidgetTester tester, {
    LinkListFilters filters = LinkListFilters.empty,
    int inboxCount = 7,
  }) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              Scaffold(body: LinksListScreen(initialFilters: filters)),
        ),
        GoRoute(
          path: AppRoutes.inbox,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('pantalla de bandeja')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardSortPreferenceProvider.overrideWith(_FixedCardSortController.new),
          linksProvider.overrideWith(
            (Ref ref, LinkQuery query) =>
                Stream<List<domain.LinkCard>>.value(const <domain.LinkCard>[]),
          ),
          linkCountProvider.overrideWith(
            (Ref ref, LinkQuery query) => Stream<int>.value(0),
          ),
          statusCountsProvider.overrideWith(
            (Ref ref) => Stream<Map<CardStatus, int>>.value(
              <CardStatus, int>{
                for (final CardStatus status in CardStatus.values) status: 0,
              },
            ),
          ),
          categoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
          categoriesOfProvider.overrideWith(
            (Ref ref, String id) =>
                Stream<List<Category>>.value(const <Category>[]),
          ),
          inboxCountProvider.overrideWith(
            (Ref ref) => Stream<int>.value(inboxCount),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  group('Acceso a la Bandeja desde la lista', () {
    testWidgets('la ofrece con su contador en vivo', (
      WidgetTester tester,
    ) async {
      await pumpList(tester);

      // El chip muestra etiqueta y contador juntos: "Bandeja · 7".
      expect(find.textContaining('Bandeja'), findsOneWidget);
      expect(find.textContaining('7'), findsWidgets);
    });

    testWidgets('pulsarla navega a la Bandeja', (WidgetTester tester) async {
      await pumpList(tester);

      // El chip vive en una fila con desplazamiento horizontal y puede quedar
      // fuera del viewport en la pantalla de test.
      await tester.ensureVisible(find.textContaining('Bandeja'));
      await tester.pump();
      await tester.tap(find.textContaining('Bandeja'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('pantalla de bandeja'), findsOneWidget);
    });

    testWidgets('dentro de la Bandeja el acceso desaparece', (
      WidgetTester tester,
    ) async {
      // Ofrecer "ir a la Bandeja" estando ya en ella sería ruido.
      await pumpList(
        tester,
        filters: const LinkListFilters(uncategorized: true),
      );

      expect(find.textContaining('Bandeja'), findsNothing);
    });
  });
}
