import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reglas de dependencia entre capas (§5 del plan).
///
/// Se comprueban leyendo los imports porque son reglas que ninguna herramienta
/// del proyecto impone por sí sola: sin este test, la primera vez que alguien
/// importe Drift en un widget nadie se entera.
void main() {
  List<File> dartFilesUnder(String path) {
    final Directory dir = Directory(path);
    if (!dir.existsSync()) {
      return <File>[];
    }
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .where((File f) => !f.path.endsWith('.g.dart'))
        .where((File f) => !f.path.endsWith('.freezed.dart'))
        .toList();
  }

  List<String> importsOf(File file) {
    return file
        .readAsLinesSync()
        .where((String l) => l.trimLeft().startsWith('import '))
        .toList();
  }

  /// Todos los ficheros que [entry] alcanza siguiendo imports relativos.
  ///
  /// Comprobar sólo los imports directos deja pasar el caso que de verdad
  /// importa: un fichero de dominio que importa un helper "neutral" que a su
  /// vez importa Drift. La regla se cumpliría en apariencia y se incumpliría
  /// de hecho.
  Set<File> transitiveClosure(File entry) {
    final Set<String> visited = <String>{};
    final Set<File> result = <File>{};
    final List<File> pending = <File>[entry];

    while (pending.isNotEmpty) {
      final File current = pending.removeLast();
      final String path = current.absolute.path;
      if (!visited.add(path) || !current.existsSync()) {
        continue;
      }
      result.add(current);

      for (final String line in importsOf(current)) {
        final RegExpMatch? match = RegExp("import\\s+'([^']+)'").firstMatch(line);
        final String? target = match?.group(1);
        if (target == null || target.startsWith('package:') || target.startsWith('dart:')) {
          continue;
        }
        pending.add(
          File(
            Uri.file(current.parent.absolute.path + Platform.pathSeparator)
                .resolve(target)
                .toFilePath(),
          ),
        );
      }
    }
    return result;
  }

  /// Paquetes prohibidos en la clausura transitiva de un fichero.
  void expectClosureFree(
    List<File> entries,
    List<String> forbidden,
    String because,
  ) {
    for (final File entry in entries) {
      for (final File reached in transitiveClosure(entry)) {
        for (final String line in importsOf(reached)) {
          for (final String banned in forbidden) {
            expect(
              line.contains(banned),
              isFalse,
              reason:
                  '${entry.path} alcanza $banned a través de ${reached.path}.\n'
                  '$because',
            );
          }
        }
      }
    }
  }

  group('El dominio no conoce la infraestructura', () {
    final List<File> domainFiles = <File>[
      ...dartFilesUnder('lib/features/links/domain'),
      ...dartFilesUnder('lib/features/categories/domain'),
      ...dartFilesUnder('lib/features/metadata/domain'),
      ...dartFilesUnder('lib/features/sharing/domain'),
      ...dartFilesUnder('lib/features/backup/domain'),
      ...dartFilesUnder('lib/features/search/domain'),
    ];

    test('hay ficheros de dominio que comprobar', () {
      expect(domainFiles, isNotEmpty);
    });

    test('no alcanza Flutter, ni directa ni transitivamente', () {
      expectClosureFree(
        domainFiles,
        <String>['package:flutter/'],
        'El dominio debe poder ejecutarse en Dart puro.',
      );
    });

    test('no alcanza Drift, ni directa ni transitivamente', () {
      expectClosureFree(
        domainFiles,
        <String>['package:drift/'],
        'Cambiar de persistencia no debe obligar a tocar el dominio.',
      );
    });

    test('no alcanza Riverpod, ni directa ni transitivamente', () {
      expectClosureFree(
        domainFiles,
        <String>['riverpod'],
        'El dominio no gestiona estado.',
      );
    });
  });

  group('La presentación no toca la base de datos directamente', () {
    final List<File> presentationFiles = <File>[
      ...dartFilesUnder('lib/features/links/presentation'),
      ...dartFilesUnder('lib/features/categories/presentation'),
      ...dartFilesUnder('lib/features/kanban/presentation'),
      ...dartFilesUnder('lib/features/sharing/presentation'),
      ...dartFilesUnder('lib/features/backup/presentation'),
      ...dartFilesUnder('lib/features/settings/presentation'),
      ...dartFilesUnder('lib/features/search/presentation'),
      ...dartFilesUnder('lib/shared'),
    ];

    test('ningún widget importa Drift', () {
      for (final File file in presentationFiles) {
        for (final String line in importsOf(file)) {
          expect(
            line.contains('package:drift/'),
            isFalse,
            reason:
                '${file.path} importa Drift. La UI habla con repositorios a '
                'través de providers.',
          );
        }
      }
    });

    test('ningún widget importa app_database', () {
      for (final File file in presentationFiles) {
        for (final String line in importsOf(file)) {
          expect(
            line.contains('app_database'),
            isFalse,
            reason: '${file.path} importa la base de datos directamente.',
          );
        }
      }
    });
  });

  group('El design system es la única fuente de color', () {
    test('ningún widget declara un Color literal', () {
      final RegExp literal = RegExp(r'Color\(0x[0-9a-fA-F]{8}\)');
      final List<File> uiFiles = <File>[
        ...dartFilesUnder('lib/features'),
        ...dartFilesUnder('lib/shared'),
      ];

      for (final File file in uiFiles) {
        final String source = file.readAsStringSync();
        expect(
          literal.hasMatch(source),
          isFalse,
          reason:
              '${file.path} declara un color literal. Todo color sale de '
              'core/theme/tokens.dart.',
        );
      }
    });
  });
}
