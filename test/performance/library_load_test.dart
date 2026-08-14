@Tags(<String>['load'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Batch;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/features/backup/data/library_backup_service.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_query.dart';

import '../core/database/database_test_helpers.dart';

/// Prueba de carga de la F16: 5.000 enlaces, que es el volumen que el plan usa
/// como techo del MVP.
///
/// La base es **un archivo en disco**, no memoria: lo que se quiere medir es lo
/// que hace la app en un dispositivo, y una base en RAM no paga ni el coste de
/// abrir el archivo ni el de leer páginas.
///
/// Los umbrales no son inventados aquí: §4.3 del plan fija que la búsqueda debe
/// responder por debajo de **150 ms** y que superarlo es lo que obligaría a
/// migrar a FTS5.
const int _cardCount = 5000;
const int _categoryCount = 12;

String _buildBackupJson() {
  final DateTime base = DateTime.utc(2026, 1, 1);
  return jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'application': 'SambaLinks',
    'appVersion': '1.0.0',
    'exportedAt': base.toIso8601String(),
    'counts': <String, int>{
      'cards': _cardCount,
      'categories': _categoryCount,
      'cardCategories': _cardCount,
    },
    'settings': <String, Object?>{},
    'categories': <Object?>[
      for (int i = 0; i < _categoryCount; i++)
        <String, Object?>{
          'id': 'cat-$i',
          'name': 'Categoría $i',
          'color': '#B9ECFA',
          'sortOrder': i,
          'createdAt': base.toIso8601String(),
          'updatedAt': base.toIso8601String(),
        },
    ],
    'cards': <Object?>[
      for (int i = 0; i < _cardCount; i++)
        <String, Object?>{
          'id': 'card-${i.toString().padLeft(5, '0')}',
          'url': 'https://ejemplo.com/$i?utm_source=x',
          'canonicalUrl': 'https://ejemplo.com/$i',
          'domain': 'ejemplo.com',
          // Una sola aguja en todo el pajar, para que la búsqueda tenga que
          // recorrerlo entero antes de encontrarla.
          'title': i == 4137
              ? 'Aguja medible del benchmark'
              : 'Enlace número $i',
          'description': 'Descripción del enlace $i',
          'notes': i.isEven ? 'nota par $i' : null,
          'platform': LinkPlatform.values[i % LinkPlatform.values.length].name,
          'status': CardStatus.values[i % CardStatus.values.length].name,
          'metadataStatus':
              MetadataStatus.values[i % MetadataStatus.values.length].name,
          'createdAt': base.add(Duration(minutes: i)).toIso8601String(),
          'updatedAt': base.add(Duration(minutes: i)).toIso8601String(),
        },
    ],
    // Tres cuartas partes con categoría: el resto se queda en la Bandeja, que
    // es la consulta que más cuesta porque es un LEFT JOIN con IS NULL.
    'cardCategories': <Object?>[
      for (int i = 0; i < _cardCount; i++)
        if (i % 4 != 0)
          <String, Object?>{
            'cardId': 'card-${i.toString().padLeft(5, '0')}',
            'categoryId': 'cat-${i % _categoryCount}',
            'createdAt': base.toIso8601String(),
          },
    ],
  });
}

void main() {
  late Directory dir;
  late AppDatabase db;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('sambalinks-load');
    db = AppDatabase(NativeDatabase(File('${dir.path}/sambalinks.sqlite')));
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  /// Mide [action] en **microsegundos** tras una ejecución de calentamiento.
  ///
  /// En milisegundos todas estas consultas dan 0 sobre 5.000 filas, y un umbral
  /// que se cumple con un 0 no vigila nada: no distingue "rápido" de "no se ha
  /// ejecutado". En microsegundos el número dice algo y el margen real contra
  /// los 150 ms de §4.3 queda a la vista.
  Future<int> measure(Future<void> Function() action) async {
    await action();
    final Stopwatch stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();
    return stopwatch.elapsedMicroseconds;
  }

  /// Los 150 ms de §4.3, en la unidad que se mide.
  const int limit = 150 * 1000;

  test('5.000 enlaces importados responden dentro de los umbrales', () async {
    final LibraryBackupService service = LibraryBackupService(db);

    final Stopwatch importWatch = Stopwatch()..start();
    final ImportReport report = await service.import(
      service.parse(_buildBackupJson()),
      mode: ImportMode.replace,
    );
    importWatch.stop();

    expect(report.cardsAdded, _cardCount);

    // Primera página de la lista: es lo que se dibuja al abrir la app, así que
    // marca el suelo del arranque en frío.
    final int firstPage = await measure(
      () => db.cardsDao.getCards(limit: 40).then((_) {}),
    );
    // Desplazarse es pedir la página siguiente con un offset alto, que es el
    // caso malo de `limit`/`offset`.
    final int deepPage = await measure(
      () => db.cardsDao.getCards(limit: 40, offset: 4000).then((_) {}),
    );
    final int search = await measure(
      () => db.cardsDao
          .getCards(filter: const CardFilter(query: 'aguja medible'), limit: 40)
          .then((_) {}),
    );
    final int inbox = await measure(
      () => db.cardsDao
          .getCards(filter: const CardFilter(uncategorized: true), limit: 40)
          .then((_) {}),
    );
    final int counts = await measure(
      () => db.cardsDao.watchCountsByStatus().first.then((_) {}),
    );

    // ignore: avoid_print
    print(
      'Carga con $_cardCount enlaces — '
      'import: ${importWatch.elapsedMilliseconds} ms · '
      'primera página: $firstPage µs · '
      'página profunda: $deepPage µs · '
      'búsqueda: $search µs · '
      'bandeja: $inbox µs · '
      'contadores: $counts µs',
    );

    final List<Card> needle = await db.cardsDao.getCards(
      filter: const CardFilter(query: 'aguja medible'),
      limit: 40,
    );
    expect(needle.single.id, 'card-04137');

    expect(search, lessThan(limit), reason: 'búsqueda: $search µs');
    expect(firstPage, lessThan(limit), reason: 'primera página: $firstPage µs');
    expect(deepPage, lessThan(limit), reason: 'página profunda: $deepPage µs');
    expect(inbox, lessThan(limit), reason: 'bandeja: $inbox µs');
    expect(counts, lessThan(limit), reason: 'contadores: $counts µs');
  });

  test('la biblioteca cargada no degrada el conteo por categoría', () async {
    await db.batch((Batch batch) {
      for (int i = 0; i < _cardCount; i++) {
        batch.insert(
          db.cards,
          buildCard(
            id: 'card-$i',
            canonicalUrl: 'https://ejemplo.com/$i',
            title: 'Enlace $i',
            status: CardStatus.values[i % CardStatus.values.length],
          ),
        );
      }
    });

    final int total = await measure(
      () => db.cardsDao.watchCount().first.then((_) {}),
    );
    expect(total, lessThan(150 * 1000), reason: 'conteo total: $total µs');
  });
}
