import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/app.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/tokens.dart';
import 'package:sambalinks/features/categories/domain/category.dart';

SharedMediaFile _text(String value) =>
    SharedMediaFile(path: value, type: SharedMediaType.text);

/// Monta la aplicación con los providers de datos sustituidos por dobles.
///
/// Los tests de widget comprueban widgets, no persistencia: eso ya lo cubren
/// los tests de DAO y de repositorio. Meter Drift aquí sólo aporta timers vivos
/// y cierres de base que se cuelgan dentro de la zona de async simulado de
/// flutter_test. El cableado real de extremo a extremo se verifica en el
/// dispositivo y quedará cubierto por los tests de integración de la F16.
Future<void> _pumpApp(
  WidgetTester tester, {
  List<SharedMediaFile> initial = const <SharedMediaFile>[],
  Stream<List<SharedMediaFile>>? stream,
  List<Category> categories = const <Category>[],
}) async {
  ReceiveSharingIntent.setMockValues(
    initialMedia: initial,
    mediaStream: stream ?? const Stream<List<SharedMediaFile>>.empty(),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        seedProvider.overrideWith((Ref ref) async {}),
        categoriesProvider.overrideWith(
          (Ref ref) => Stream<List<Category>>.value(categories),
        ),
      ],
      child: const SambaLinksApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Category _category(String name, String color) => Category(
  id: name,
  name: name,
  color: color,
  createdAt: DateTime.utc(2026, 8, 12),
  updatedAt: DateTime.utc(2026, 8, 12),
);

void main() {
  group('Arranque de la aplicación', () {
    testWidgets('muestra los textos resueltos desde el ARB en español', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text('SambaLinks'), findsOneWidget);
      expect(find.text('Tu bandeja está vacía'), findsOneWidget);
    });

    testWidgets('el locale activo es español', (WidgetTester tester) async {
      await _pumpApp(tester);

      final BuildContext context = tester.element(find.byType(Scaffold));
      expect(Localizations.localeOf(context).languageCode, 'es');
    });
  });

  group('Catálogo de localización', () {
    test('sólo declara español como locale soportado', () {
      expect(L10n.supportedLocales, <Locale>[const Locale('es')]);
    });
  });

  group('Tema', () {
    testWidgets('expone SambaColors en claro y en oscuro', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      final BuildContext context = tester.element(find.byType(Scaffold));
      expect(Theme.of(context).extension<SambaColors>(), isNotNull);
    });
  });

  group('Los providers llegan hasta la UI', () {
    testWidgets('pinta las categorías que emite el provider', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        categories: <Category>[
          _category('Leer después', '#B9ECFA'),
          _category('Inspiración', '#B9F7D8'),
        ],
      );

      expect(find.text('Leer después'), findsOneWidget);
      expect(find.text('Inspiración'), findsOneWidget);
    });

    testWidgets('sin categorías no rompe la pantalla vacía', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text('Tu bandeja está vacía'), findsOneWidget);
    });
  });

  group('Recepción de contenido compartido', () {
    testWidgets('muestra la URL cuando la app se abre desde un compartir', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        initial: <SharedMediaFile>[
          _text('Mira esto https://instagram.com/p/ABC123/'),
        ],
      );

      // Muestra la canónica, no la URL cruda: la Fase 4 ya está en el flujo.
      expect(find.text('https://instagram.com/p/ABC123'), findsOneWidget);
      expect(find.text('instagram'), findsOneWidget);
      expect(find.text('app cerrada'), findsOneWidget);
    });

    testWidgets('muestra la URL que llega con la app ya abierta', (
      WidgetTester tester,
    ) async {
      final StreamController<List<SharedMediaFile>> controller =
          StreamController<List<SharedMediaFile>>();
      addTearDown(controller.close);

      await _pumpApp(tester, stream: controller.stream);
      expect(find.text('Tu bandeja está vacía'), findsOneWidget);

      controller.add(<SharedMediaFile>[_text('https://x.com/user/status/1')]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('https://x.com/user/status/1'), findsOneWidget);
      expect(find.text('app en segundo plano'), findsOneWidget);
    });
  });
}
