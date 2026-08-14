import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/kanban/presentation/kanban_screen.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/features/links/domain/link_repository.dart';

import '../../core/database/database_test_helpers.dart';

domain.LinkCard _card(String id, CardStatus status) {
  final DateTime now = DateTime.utc(2026, 8, 13);
  return domain.LinkCard(
    id: id,
    url: 'https://ejemplo.com/$id',
    canonicalUrl: 'https://ejemplo.com/$id',
    domain: 'ejemplo.com',
    title: 'Enlace $id',
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase db;
  late LinkRepository repository;

  setUp(() {
    db = openTestDatabase();
  });
  tearDown(() => db.close());

  Future<ProviderContainer> pumpBoard(
    WidgetTester tester,
    List<domain.LinkCard> cards,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // El tablero se alimenta de streams; se sirven desde memoria para que
          // no dependa de Drift, cuyos streams no resuelven bajo el reloj
          // simulado de testWidgets.
          scopedStatusCountsProvider.overrideWith(
            (Ref ref, LinkQuery query) =>
                Stream<Map<CardStatus, int>>.value(<CardStatus, int>{
                  for (final CardStatus status in CardStatus.values)
                    status: cards
                        .where((domain.LinkCard c) => c.status == status)
                        .length,
                }),
          ),
          linksProvider.overrideWith(
            (Ref ref, LinkQuery query) => Stream<List<domain.LinkCard>>.value(
              cards
                  .where(
                    (domain.LinkCard c) =>
                        query.filter.statuses?.contains(c.status) ?? true,
                  )
                  .toList(),
            ),
          ),
          categoriesOfProvider.overrideWith(
            (Ref ref, String id) => const Stream<List<Never>>.empty(),
          ),
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          home: const Scaffold(body: KanbanScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return ProviderScope.containerOf(
      tester.element(find.byType(KanbanScreen)),
      listen: false,
    );
  }

  group('Tablero', () {
    testWidgets('muestra las tres columnas con sus contadores', (
      WidgetTester tester,
    ) async {
      await pumpBoard(tester, <domain.LinkCard>[
        _card('a', CardStatus.pending),
        _card('b', CardStatus.pending),
        _card('c', CardStatus.active),
      ]);

      // Cada nombre aparece en la cabecera de su columna y en la píldora de
      // estado de cada tarjeta, así que se comprueba la presencia, no el número.
      expect(find.text('Pendiente'), findsWidgets);
      expect(find.text('Activo'), findsWidgets);
      expect(find.text('Atendido'), findsWidgets);
      // 2 pendientes, 1 activo, 0 atendidos.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('una biblioteca vacía muestra el estado vacío', (
      WidgetTester tester,
    ) async {
      await pumpBoard(tester, const <domain.LinkCard>[]);

      expect(find.text('Organiza tu flujo'), findsOneWidget);
    });

    testWidgets('una columna sin enlaces lo dice', (
      WidgetTester tester,
    ) async {
      await pumpBoard(tester, <domain.LinkCard>[
        _card('a', CardStatus.pending),
      ]);

      expect(find.text('Nada aquí todavía'), findsWidgets);
    });
  });

  group('Cambio de estado', () {
    testWidgets(
      'el menú accesible mueve la tarjeta y persiste — criterios 10-11 de §55',
      (WidgetTester tester) async {
        // Arrastrar es incómodo en móvil e inalcanzable para un lector de
        // pantalla: el menú es la vía que tiene que funcionar siempre.
        final domain.LinkCard card = _card('a', CardStatus.pending);
        final ProviderContainer container = await pumpBoard(
          tester,
          <domain.LinkCard>[card],
        );
        repository = container.read(linkRepositoryProvider);
        await repository.create(card);

        await tester.tap(find.byIcon(Icons.swap_horiz).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Mover a Activo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final domain.LinkCard? stored = await repository.findById('a');
        expect(stored!.status, CardStatus.active);
        // §43: mover no puede alterar la fecha de creación.
        //
        // Se compara por instante y no con `==`: Drift devuelve las fechas en
        // hora local, así que el mismo momento no es igual a su original en
        // UTC. Ver la nota sobre el exportador en §12 del plan.
        expect(stored.createdAt.isAtSameMomentAs(card.createdAt), isTrue);
        expect(stored.updatedAt.isAfter(card.updatedAt), isTrue);
      },
    );

    testWidgets('el menú no ofrece el estado en el que ya está', (
      WidgetTester tester,
    ) async {
      await pumpBoard(tester, <domain.LinkCard>[
        _card('a', CardStatus.pending),
      ]);

      await tester.tap(find.byIcon(Icons.swap_horiz).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mover a Activo'), findsOneWidget);
      expect(find.text('Mover a Atendido'), findsOneWidget);
      expect(find.text('Mover a Pendiente'), findsNothing);
    });
  });
}
