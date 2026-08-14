import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/database/daos/settings_dao.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/backup/data/library_backup_service.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/settings/presentation/appearance_section.dart';
import 'package:sambalinks/features/settings/presentation/danger_zone_section.dart';

import '../../core/database/database_test_helpers.dart';

/// El texto "Borrar todo" está en el botón de la sección y en el del diálogo.
FilledButton _dialogButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(FilledButton, 'Borrar todo'),
  ),
);

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  Future<ProviderContainer> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // Sin streams de Drift vivos en tests de widget.
          statusCountsProvider.overrideWith(
            (Ref ref) => Stream<Map<CardStatus, int>>.value(
              const <CardStatus, int>{CardStatus.pending: 4},
            ),
          ),
          categoriesProvider.overrideWith(
            (Ref ref) => Stream<List<Category>>.value(const <Category>[]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
      listen: false,
    );
  }

  group('Apariencia', () {
    testWidgets('por defecto es Sistema (§36)', (WidgetTester tester) async {
      final ProviderContainer container = await pump(
        tester,
        const AppearanceSection(),
      );

      expect(find.text('Sistema'), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(container.read(themeModeProvider).asData?.value, ThemeMode.system);
    });

    testWidgets('elegir un modo lo persiste en settings', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pump(
        tester,
        const AppearanceSection(),
      );

      await tester.tap(find.text('Oscuro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(container.read(themeModeProvider).asData?.value, ThemeMode.dark);
      // Lo que importa: sobrevive a un reinicio.
      expect(await db.settingsDao.read<String>(SettingsKeys.theme), 'dark');
    });
  });

  group('Borrar biblioteca', () {
    testWidgets('exige escribir BORRAR antes de habilitar el botón', (
      WidgetTester tester,
    ) async {
      await pump(tester, const DangerZoneSection());

      await tester.tap(find.text('Borrar todo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('¿Borrar toda la biblioteca?'), findsOneWidget);

      // El botón del diálogo está deshabilitado hasta escribir la palabra.
      expect(_dialogButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'BORRAR');
      await tester.pump();

      expect(_dialogButton(tester).onPressed, isNotNull);
    });

    testWidgets('una palabra equivocada no habilita el borrado', (
      WidgetTester tester,
    ) async {
      await pump(tester, const DangerZoneSection());
      await tester.tap(find.text('Borrar todo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(find.byType(TextField), 'borrar');
      await tester.pump();

      expect(_dialogButton(tester).onPressed, isNull);
    });

    test('borra enlaces y categorías pero conserva los ajustes', () async {
      await db.settingsDao.write(SettingsKeys.theme, 'dark');
      await DriftHelpers.linkRepository(db).create(
        LinkCard(
          id: 'c1',
          url: 'https://ejemplo.com/a',
          canonicalUrl: 'https://ejemplo.com/a',
          domain: 'ejemplo.com',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await DriftHelpers.categoryRepository(db).create(name: 'Ideas');

      await LibraryBackupService(db).clearLibrary();

      expect(await db.select(db.cards).get(), isEmpty);
      expect(await db.select(db.categories).get(), isEmpty);
      // El tema no es parte de la biblioteca.
      expect(await db.settingsDao.read<String>(SettingsKeys.theme), 'dark');
    });
  });
}
