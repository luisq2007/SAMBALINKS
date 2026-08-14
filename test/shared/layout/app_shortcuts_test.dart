import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/shared/layout/app_shortcuts.dart';

void main() {
  late List<String> fired;

  setUp(() => fired = <String>[]);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShortcuts(
          actions: AppShortcutActions(
            onSearch: () => fired.add('buscar'),
            onAddLink: () => fired.add('añadir'),
            onFilters: () => fired.add('filtros'),
          ),
          child: const Focus(autofocus: true, child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> press(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    LogicalKeyboardKey? modifier,
    bool shift = false,
  }) async {
    if (modifier != null) {
      await tester.sendKeyDownEvent(modifier);
    }
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    }
    await tester.sendKeyEvent(key);
    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    }
    if (modifier != null) {
      await tester.sendKeyUpEvent(modifier);
    }
    await tester.pump();
  }

  group('Atajos de escritorio (§40)', () {
    testWidgets('CMD+K busca', (WidgetTester tester) async {
      await pump(tester);
      await press(
        tester,
        LogicalKeyboardKey.keyK,
        modifier: LogicalKeyboardKey.metaLeft,
      );

      expect(fired, <String>['buscar']);
    });

    testWidgets('CMD+F busca, no filtra — corrige §40 (ver §4.5)', (
      WidgetTester tester,
    ) async {
      // En cualquier app de escritorio CMD+F es buscar. Romper esa expectativa
      // se paga en cada uso, así que los filtros van a CMD+SHIFT+F.
      await pump(tester);
      await press(
        tester,
        LogicalKeyboardKey.keyF,
        modifier: LogicalKeyboardKey.metaLeft,
      );

      expect(fired, <String>['buscar']);
    });

    testWidgets('CMD+SHIFT+F abre los filtros', (WidgetTester tester) async {
      await pump(tester);
      await press(
        tester,
        LogicalKeyboardKey.keyF,
        modifier: LogicalKeyboardKey.metaLeft,
        shift: true,
      );

      expect(fired, <String>['filtros']);
    });

    testWidgets('CMD+N añade un enlace', (WidgetTester tester) async {
      await pump(tester);
      await press(
        tester,
        LogicalKeyboardKey.keyN,
        modifier: LogicalKeyboardKey.metaLeft,
      );

      expect(fired, <String>['añadir']);
    });

    testWidgets('CTRL sirve igual que CMD, para Windows y Linux', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await press(
        tester,
        LogicalKeyboardKey.keyN,
        modifier: LogicalKeyboardKey.controlLeft,
      );

      expect(fired, <String>['añadir']);
    });

    testWidgets('una tecla sin modificador no dispara nada', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await press(tester, LogicalKeyboardKey.keyK);
      await press(tester, LogicalKeyboardKey.keyN);

      expect(fired, isEmpty);
    });
  });
}
