import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/links/presentation/add_link_sheet.dart';
import 'package:sambalinks/shared/layout/clipboard_link_suggestion.dart';

import '../../core/database/database_test_helpers.dart';

/// Portapapeles simulado: `Clipboard.getData` habla con el canal de la
/// plataforma, que en un test no existe.
class _FakeClipboard {
  _FakeClipboard(this.text);

  String? text;
  int reads = 0;

  void install(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.getData') {
          reads++;
          return <String, dynamic>{'text': text};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          home: const Scaffold(
            body: ClipboardLinkSuggestion(child: Text('contenido')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
    'sugiere el enlace copiado y lo lleva a la hoja',
    (WidgetTester tester) async {
      _FakeClipboard(
        'Mira esto https://ejemplo.com/articulo?utm_source=x',
      ).install(tester);

      await pump(tester);

      expect(find.text('Tienes un enlace copiado'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      // La hoja llega con la URL puesta: el usuario ya dijo que sí.
      expect(find.byType(AddLinkSheet), findsOneWidget);
      expect(
        tester.widget<AddLinkSheet>(find.byType(AddLinkSheet)).initialUrl,
        'https://ejemplo.com/articulo?utm_source=x',
      );
    },
    variant: TargetPlatformVariant.desktop(),
  );

  testWidgets(
    'descartar no vuelve a proponer el mismo enlace',
    (WidgetTester tester) async {
      _FakeClipboard('https://ejemplo.com/uno').install(tester);

      await pump(tester);
      expect(find.text('Tienes un enlace copiado'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Ahora no'));
      await tester.pump();
      expect(find.text('Tienes un enlace copiado'), findsNothing);

      // Volver a la ventana no puede resucitar lo ya descartado.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tienes un enlace copiado'), findsNothing);
    },
    variant: TargetPlatformVariant.desktop(),
  );

  testWidgets(
    'no propone un enlace que ya está en la biblioteca',
    (WidgetTester tester) async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'existente',
          url: 'https://ejemplo.com/uno',
          canonicalUrl: 'https://ejemplo.com/uno',
        ),
      );
      _FakeClipboard('https://ejemplo.com/uno').install(tester);

      await pump(tester);

      expect(find.text('Tienes un enlace copiado'), findsNothing);
    },
    variant: TargetPlatformVariant.desktop(),
  );

  testWidgets(
    'en móvil no lee el portapapeles jamás',
    (WidgetTester tester) async {
      // La F9.5 fijó que la app no fisgonea el portapapeles en Android: el
      // sistema muestra un aviso en cada lectura. Este test falla si alguien
      // quita el gate de plataforma.
      final _FakeClipboard clipboard = _FakeClipboard('https://ejemplo.com/uno')
        ..install(tester);

      await pump(tester);

      expect(clipboard.reads, 0);
      expect(find.text('Tienes un enlace copiado'), findsNothing);
      expect(find.text('contenido'), findsOneWidget);
    },
    variant: TargetPlatformVariant.mobile(),
  );
}
