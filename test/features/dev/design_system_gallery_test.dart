import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/app.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/core/theme/tokens.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/shared/widgets/widgets.dart';

import '../../core/database/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  /// La raíz lee la preferencia de tema desde `settings`, así que necesita un
  /// ProviderScope con una base en memoria.
  Future<void> pumpGallery(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const SambaLinksApp(initialRoute: '/dev/gallery'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> setSurface(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('la galería contiene los ocho componentes base', (
    WidgetTester tester,
  ) async {
    await setSurface(tester, const Size(1200, 1000));
    await pumpGallery(tester);

    expect(find.byType(SambaButton), findsWidgets);
    expect(find.byType(SambaTextField), findsNWidgets(2));
    expect(find.byType(StatusPill), findsWidgets);
    expect(find.byType(CategoryChip), findsNWidgets(2));
    expect(find.byType(SambaCard), findsWidgets);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(SambaMenu<String>), findsWidgets);

    await tester.ensureVisible(find.text('Abrir panel'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Abrir panel'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SambaSheet), findsOneWidget);
    expect(find.text('Editar enlace'), findsOneWidget);
  });

  for (final (String name, Size size) in <(String, Size)>[
    ('móvil', const Size(390, 844)),
    ('escritorio', const Size(1440, 900)),
  ]) {
    testWidgets('no desborda en tamaño $name', (WidgetTester tester) async {
      await setSurface(tester, size);
      await pumpGallery(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Galería de componentes'), findsOneWidget);
    });
  }

  testWidgets('el control de la galería alterna claro y oscuro', (
    WidgetTester tester,
  ) async {
    await pumpGallery(tester);
    BuildContext context = tester.element(find.byType(Scaffold));
    final Brightness initial = Theme.of(context).brightness;

    final Finder toggleIcon = find.byIcon(
      initial == Brightness.light ? Icons.dark_mode : Icons.light_mode,
    );
    expect(toggleIcon, findsOneWidget);
    final Finder toggleButton = find.ancestor(
      of: toggleIcon,
      matching: find.byType(IconButton),
    );
    await tester.tap(toggleButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byIcon(
        initial == Brightness.light ? Icons.light_mode : Icons.dark_mode,
      ),
      findsOneWidget,
    );
    context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, isNot(initial));
  });

  testWidgets('un botón en carga está deshabilitado y conserva su etiqueta', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _LocalizedHarness(
        child: SambaButton(
          label: 'Cargando',
          onPressed: () => taps += 1,
          loading: true,
        ),
      ),
    );

    await tester.tap(find.byType(SambaButton));

    expect(taps, 0);
    expect(find.text('Cargando'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('StatusPill usa el glosario español', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const _LocalizedHarness(
        child: Wrap(
          children: <Widget>[
            StatusPill(status: CardStatus.pending),
            StatusPill(status: CardStatus.active),
            StatusPill(status: CardStatus.done),
          ],
        ),
      ),
    );

    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('Atendido'), findsOneWidget);
  });

  test('los tokens de categoría aceptan RGB y rechazan entradas inválidas', () {
    expect(SambaPalette.tryParseHex('#B9ECFA'), SambaPalette.arctic);
    expect(SambaPalette.tryParseHex('B9ECFA'), isNull);
    expect(SambaPalette.tryParseHex('#XYZXYZ'), isNull);
  });

  test('la escala de movimiento conserva los tres niveles del plan', () {
    expect(MotionDurations.micro, const Duration(milliseconds: 120));
    expect(MotionDurations.transition, const Duration(milliseconds: 220));
    expect(MotionDurations.panel, const Duration(milliseconds: 320));
  });
}

class _LocalizedHarness extends StatelessWidget {
  const _LocalizedHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
