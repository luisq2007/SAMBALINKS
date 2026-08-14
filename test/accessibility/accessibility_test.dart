import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/categories/presentation/categories_screen.dart';
import 'package:sambalinks/features/kanban/presentation/kanban_screen.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/features/links/domain/link_query.dart' show CardSort;
import 'package:sambalinks/features/links/presentation/links_list_screen.dart';
import 'package:sambalinks/features/settings/presentation/appearance_section.dart';
import 'package:sambalinks/features/settings/presentation/danger_zone_section.dart';

import '../core/database/database_test_helpers.dart';

/// Paso de accesibilidad de la F15.
///
/// Las tres guías que se comprueban son las de `flutter_test`, no criterios
/// propios: objetivo táctil mínimo de 44 px (§15 del plan, que es también el
/// mínimo de Apple), toda zona pulsable con etiqueta que un lector de pantalla
/// pueda leer, y contraste de texto suficiente. Se ejecutan sobre las
/// pantallas reales en **tema claro y oscuro**, porque el contraste cambia con
/// el tema y la paleta de §9 está calculada para ambos.
class _FixedCardSortController extends CardSortController {
  @override
  Future<CardSort> build() async => CardSort.newest;

  @override
  Future<void> setSort(CardSort sort) async {
    state = AsyncData<CardSort>(sort);
  }
}

domain.LinkCard _card(int index, {CardStatus status = CardStatus.pending}) {
  final DateTime now = DateTime.utc(2026, 8, 14);
  return domain.LinkCard(
    id: 'card-$index',
    url: 'https://ejemplo.com/$index',
    canonicalUrl: 'https://ejemplo.com/$index',
    domain: 'ejemplo.com',
    title: 'Enlace $index',
    description: 'Descripción del enlace $index',
    platform: LinkPlatform.web,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

final List<domain.LinkCard> _cards = <domain.LinkCard>[
  _card(0),
  _card(1, status: CardStatus.active),
  _card(2, status: CardStatus.done),
];

final List<Category> _categories = <Category>[
  Category(
    id: 'cat-1',
    name: 'Inspiración',
    color: '#B9ECFA',
    icon: 'lightbulb',
    createdAt: DateTime.utc(2026, 8, 14),
    updatedAt: DateTime.utc(2026, 8, 14),
  ),
];

void main() {
  late AppDatabase db;

  setUp(() {
    db = openTestDatabase();
    ReceiveSharingIntent.setMockValues(
      initialMedia: const [],
      mediaStream: const Stream.empty(),
    );
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    required ThemeData theme,
    Size size = const Size(420, 900),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          cardSortPreferenceProvider.overrideWith(_FixedCardSortController.new),
          linksProvider.overrideWith(
            (Ref ref, LinkQuery query) => Stream<List<domain.LinkCard>>.value(
              _cards
                  .where(
                    (domain.LinkCard c) =>
                        query.filter.statuses?.contains(c.status) ?? true,
                  )
                  .toList(),
            ),
          ),
          linkCountProvider.overrideWith(
            (Ref ref, LinkQuery query) => Stream<int>.value(_cards.length),
          ),
          statusCountsProvider.overrideWith(
            (Ref ref) => Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
              for (final CardStatus status in CardStatus.values)
                status: _cards
                    .where((domain.LinkCard c) => c.status == status)
                    .length,
            }),
          ),
          scopedStatusCountsProvider.overrideWith(
            (Ref ref, LinkQuery query) =>
                Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
                  for (final CardStatus status in CardStatus.values)
                    status: _cards
                        .where((domain.LinkCard c) => c.status == status)
                        .length,
                }),
          ),
          inboxCountProvider.overrideWith((Ref ref) => Stream<int>.value(1)),
          categoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(_categories),
          ),
          categoriesOfProvider.overrideWith(
            (Ref ref, String id) => Stream<List<Category>>.value(_categories),
          ),
          categorySummariesProvider.overrideWith(
            (Ref ref) => Stream<List<CategorySummary>>.value(<CategorySummary>[
              for (final Category category in _categories)
                CategorySummary(category: category, linkCount: 2),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: theme,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'Lista': LinksListScreen.new,
    'Kanban': KanbanScreen.new,
    'Categorías': CategoriesScreen.new,
    'Ajustes · Apariencia': AppearanceSection.new,
    'Ajustes · Zona de riesgo': DangerZoneSection.new,
  };

  for (final MapEntry<String, Widget Function()> entry in screens.entries) {
    for (final MapEntry<String, ThemeData> themed in <String, ThemeData>{
      'claro': AppTheme.light,
      'oscuro': AppTheme.dark,
    }.entries) {
      testWidgets('${entry.key} (${themed.key}) cumple las guías', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        await pump(tester, entry.value(), theme: themed.value);

        // 44 px es el mínimo que fija §15 del plan, no los 48 de Android.
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      });
    }
  }

  // Las hojas modales son donde se acumulan los controles pequeños —
  // interruptores, chips, iconos de cerrar—, así que se comprueban abiertas y
  // no sólo la pantalla que las lanza.
  testWidgets('el panel de filtros abierto cumple las guías', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pump(tester, const LinksListScreen(), theme: AppTheme.dark);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filtros'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('el detalle de un enlace cumple las guías', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pump(tester, const LinksListScreen(), theme: AppTheme.dark);

    await tester.tap(find.text('Enlace 0'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
