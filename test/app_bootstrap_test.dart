import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sambalinks/app.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/theme/tokens.dart';

SharedMediaFile _text(String value) =>
    SharedMediaFile(path: value, type: SharedMediaType.text);

Future<void> _pumpApp(
  WidgetTester tester, {
  List<SharedMediaFile> initial = const <SharedMediaFile>[],
  Stream<List<SharedMediaFile>>? stream,
}) async {
  ReceiveSharingIntent.setMockValues(
    initialMedia: initial,
    mediaStream: stream ?? const Stream<List<SharedMediaFile>>.empty(),
  );
  await tester.pumpWidget(const SambaLinksApp());
  await tester.pumpAndSettle();
}

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

      expect(find.text('https://instagram.com/p/ABC123/'), findsOneWidget);
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
      await tester.pumpAndSettle();

      expect(find.text('https://x.com/user/status/1'), findsOneWidget);
      expect(find.text('app en segundo plano'), findsOneWidget);
    });
  });
}
