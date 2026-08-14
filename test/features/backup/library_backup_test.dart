import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/database/daos/settings_dao.dart';
import 'package:sambalinks/features/backup/data/library_backup_service.dart';
import 'package:sambalinks/features/backup/domain/library_snapshot.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/categories/domain/category_repository.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_repository.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database_test_helpers.dart';

const Uuid _uuid = Uuid();

/// Textos que rompen serializadores mal hechos.
const List<String> _awkwardNotes = <String>[
  'Acentos: ñ á é í ó ú ü',
  'Emoji: 🔥📌✨',
  'Comillas "dobles" y \'simples\'',
  'Barra invertida \\ y salto\nde línea',
  'Tabulador\ty <html>&amp;</html>',
];

Future<void> _fillLibrary(
  AppDatabase db, {
  int cards = 200,
  int categories = 12,
}) async {
  final LinkRepository links = DriftHelpers.linkRepository(db);
  final CategoryRepository cats = DriftHelpers.categoryRepository(db);
  final Random random = Random(42);

  final List<Category> created = <Category>[
    for (int i = 0; i < categories; i++)
      (await cats.create(name: 'Categoría $i', color: '#B9ECFA')).valueOrNull!,
  ];

  for (int i = 0; i < cards; i++) {
    final DateTime when = DateTime.utc(2026, 1, 1).add(
      Duration(minutes: i, milliseconds: i * 7),
    );
    final LinkCard card = LinkCard(
      id: _uuid.v7(),
      url: 'https://ejemplo.com/$i?utm_source=x',
      canonicalUrl: 'https://ejemplo.com/$i',
      domain: 'ejemplo.com',
      title: 'Enlace número $i',
      description: 'Descripción del enlace $i',
      notes: _awkwardNotes[i % _awkwardNotes.length],
      originalSharedText: 'Mira esto https://ejemplo.com/$i',
      platform: LinkPlatform.values[i % LinkPlatform.values.length],
      status: CardStatus.values[i % CardStatus.values.length],
      metadataStatus: MetadataStatus.values[i % MetadataStatus.values.length],
      createdAt: when,
      updatedAt: when.add(const Duration(seconds: 30)),
      metadataFetchedAt: i.isEven ? when.add(const Duration(minutes: 2)) : null,
    );
    await links.create(card);

    // Unas dos relaciones por enlace de media.
    for (int k = 0; k < 2; k++) {
      await cats.assign(
        cardId: card.id,
        categoryId: created[random.nextInt(created.length)].id,
      );
    }
  }
}

void main() {
  late AppDatabase db;
  late LibraryBackupService service;

  setUp(() {
    db = openTestDatabase();
    service = LibraryBackupService(db, appVersion: '1.0.0');
  });
  tearDown(() => db.close());

  group('Ida y vuelta', () {
    test(
      'exportar, vaciar e importar devuelve la biblioteca idéntica',
      () async {
        await _fillLibrary(db);
        await db.settingsDao.write(SettingsKeys.theme, 'dark');
        await db.settingsDao.write(SettingsKeys.defaultSort, 'newest');

        final LibrarySnapshot before = await service.snapshot();
        final String json = await service.exportJson();

        // Se vacía todo, como haría una instalación nueva.
        await db.delete(db.cards).go();
        await db.delete(db.categories).go();
        expect(await db.select(db.cards).get(), isEmpty);

        await service.import(service.parse(json));
        final LibrarySnapshot after = await service.snapshot();

        expect(after.cards, hasLength(before.cards.length));
        expect(after.categories, hasLength(before.categories.length));
        expect(after.relations, hasLength(before.relations.length));

        final Map<String, LinkCard> byId = <String, LinkCard>{
          for (final LinkCard c in after.cards) c.id: c,
        };
        for (final LinkCard original in before.cards) {
          final LinkCard restored = byId[original.id]!;
          expect(restored.url, original.url);
          expect(restored.canonicalUrl, original.canonicalUrl);
          expect(restored.title, original.title);
          expect(restored.description, original.description);
          expect(restored.notes, original.notes, reason: 'nota de ${original.id}');
          expect(restored.originalSharedText, original.originalSharedText);
          expect(restored.platform, original.platform);
          expect(restored.status, original.status);
          expect(restored.metadataStatus, original.metadataStatus);
          // Precisión de milisegundos, comparando instantes: Drift devuelve las
          // fechas en hora local y el JSON las lleva en UTC.
          expect(
            restored.createdAt.isAtSameMomentAs(original.createdAt),
            isTrue,
            reason: 'createdAt de ${original.id}',
          );
          expect(
            restored.updatedAt.isAtSameMomentAs(original.updatedAt),
            isTrue,
          );
          expect(
            restored.metadataFetchedAt?.toUtc(),
            original.metadataFetchedAt?.toUtc(),
          );
        }

        expect(after.settings[SettingsKeys.theme], 'dark');
        expect(after.settings[SettingsKeys.defaultSort], 'newest');
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test('las fechas salen en UTC pase lo que pase', () async {
      await _fillLibrary(db, cards: 3, categories: 1);
      final Map<String, Object?> json =
          jsonDecode(await service.exportJson()) as Map<String, Object?>;

      for (final Object? raw in json['cards']! as List<Object?>) {
        final String created = (raw! as Map<String, Object?>)['createdAt']!
            as String;
        expect(created, endsWith('Z'), reason: 'createdAt no está en UTC');
      }
      expect(json['exportedAt'], endsWith('Z'));
    });

    test('localImage no viaja: es una ruta de este dispositivo', () async {
      await _fillLibrary(db, cards: 1, categories: 1);
      final Map<String, Object?> json =
          jsonDecode(await service.exportJson()) as Map<String, Object?>;
      final Map<String, Object?> card =
          (json['cards']! as List<Object?>).first! as Map<String, Object?>;

      expect(card.containsKey('localImage'), isFalse);
    });

    test('counts permite detectar un archivo truncado', () async {
      await _fillLibrary(db, cards: 5, categories: 2);
      final Map<String, Object?> json =
          jsonDecode(await service.exportJson()) as Map<String, Object?>;
      final Map<String, Object?> counts =
          json['counts']! as Map<String, Object?>;

      expect(counts['cards'], 5);
      expect(counts['categories'], 2);
      expect(
        counts['cardCategories'],
        (json['cardCategories']! as List<Object?>).length,
      );
    });
  });

  group('Políticas de duplicados', () {
    Future<String> backupWith({required String title}) async {
      final AppDatabase other = openTestDatabase();
      addTearDown(other.close);
      await DriftHelpers.linkRepository(other).create(
        LinkCard(
          id: 'importado',
          url: 'https://ejemplo.com/dup',
          canonicalUrl: 'https://ejemplo.com/dup',
          domain: 'ejemplo.com',
          title: title,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );
      return LibraryBackupService(other).exportJson();
    }

    Future<void> seedExisting({required DateTime updatedAt}) async {
      await DriftHelpers.linkRepository(db).create(
        LinkCard(
          id: 'existente',
          url: 'https://ejemplo.com/dup',
          canonicalUrl: 'https://ejemplo.com/dup',
          domain: 'ejemplo.com',
          title: 'el que ya estaba',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: updatedAt,
        ),
      );
    }

    test('mantener existente deja el original intacto', () async {
      await seedExisting(updatedAt: DateTime.utc(2026, 3, 1));
      final String json = await backupWith(title: 'el importado');

      final ImportReport report = await service.import(
        service.parse(json),
        duplicates: DuplicatePolicy.keepExisting,
      );

      expect(report.cardsSkipped, 1);
      final LinkCard card = (await DriftHelpers.linkRepository(
        db,
      ).findById('existente'))!;
      expect(card.title, 'el que ya estaba');
    });

    test('reemplazar con el importado gana siempre', () async {
      await seedExisting(updatedAt: DateTime.utc(2026, 12, 1));
      final String json = await backupWith(title: 'el importado');

      final ImportReport report = await service.import(
        service.parse(json),
        duplicates: DuplicatePolicy.replaceWithImported,
      );

      expect(report.cardsUpdated, 1);
      final LinkCard card = (await DriftHelpers.linkRepository(
        db,
      ).findById('existente'))!;
      // Conserva el id original para no romper relaciones ya existentes.
      expect(card.title, 'el importado');
    });

    test('mantener el más reciente compara updatedAt', () async {
      // El existente es más antiguo que el importado (junio).
      await seedExisting(updatedAt: DateTime.utc(2026, 3, 1));
      await service.import(
        service.parse(await backupWith(title: 'el importado')),
        duplicates: DuplicatePolicy.keepNewest,
      );
      expect(
        (await DriftHelpers.linkRepository(db).findById('existente'))!.title,
        'el importado',
      );
    });

    test('mantener el más reciente respeta al existente si es más nuevo', () async {
      await seedExisting(updatedAt: DateTime.utc(2026, 12, 1));
      await service.import(
        service.parse(await backupWith(title: 'el importado')),
        duplicates: DuplicatePolicy.keepNewest,
      );
      expect(
        (await DriftHelpers.linkRepository(db).findById('existente'))!.title,
        'el que ya estaba',
      );
    });

    test('nunca se crea una copia del mismo enlace', () async {
      await seedExisting(updatedAt: DateTime.utc(2026, 3, 1));
      await service.import(service.parse(await backupWith(title: 'x')));

      expect(await DriftHelpers.linkRepository(db).watchCount().first, 1);
    });
  });

  group('Modos de importación', () {
    test('combinar conserva lo que ya había', () async {
      await _fillLibrary(db, cards: 3, categories: 1);
      final AppDatabase other = openTestDatabase();
      addTearDown(other.close);
      await _fillLibrary(other, cards: 2, categories: 1);
      // Se cambian las URLs del segundo para que no choquen.
      await other.customStatement(
        "UPDATE cards SET canonical_url = canonical_url || '-b', url = url || '-b'",
      );

      await service.import(
        service.parse(await LibraryBackupService(other).exportJson()),
      );

      expect(await DriftHelpers.linkRepository(db).watchCount().first, 5);
    });

    test('reemplazar deja sólo lo importado', () async {
      await _fillLibrary(db, cards: 4, categories: 2);
      final AppDatabase other = openTestDatabase();
      addTearDown(other.close);
      await _fillLibrary(other, cards: 2, categories: 1);

      await service.import(
        service.parse(await LibraryBackupService(other).exportJson()),
        mode: ImportMode.replace,
      );

      expect(await DriftHelpers.linkRepository(db).watchCount().first, 2);
    });

    test('las categorías se fusionan por nombre, no por id', () async {
      // Dos bibliotecas distintas usan ids distintos para "Ideas". Fusionar por
      // id crearía dos categorías llamadas igual, que es lo que ve el usuario.
      final CategoryRepository categories = DriftHelpers.categoryRepository(db);
      await categories.create(name: 'Categoría 0');

      final AppDatabase other = openTestDatabase();
      addTearDown(other.close);
      await _fillLibrary(other, cards: 1, categories: 1);

      await service.import(
        service.parse(await LibraryBackupService(other).exportJson()),
      );

      final List<Category> result = await categories.watchAll().first;
      expect(result.where((Category c) => c.name == 'Categoría 0'), hasLength(1));
    });
  });

  group('Codificación', () {
    test('los acentos y emoji sobreviven al viaje por bytes', () async {
      // El test de ida y vuelta pasa strings en memoria y nunca cruza un
      // archivo real, así que no detectaba que al leer el archivo sin
      // especificar la codificación los acentos llegaban como "despuÃ©s".
      final CategoryRepository categories = DriftHelpers.categoryRepository(db);
      await categories.create(name: 'Leer después');
      await categories.create(name: 'Diseño 🔥');
      await DriftHelpers.linkRepository(db).create(
        LinkCard(
          id: 'c1',
          url: 'https://ejemplo.com/a',
          canonicalUrl: 'https://ejemplo.com/a',
          domain: 'ejemplo.com',
          title: 'Añoranza, ñu y çedilla',
          notes: 'Emoji 🔥 y comillas "así"',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );

      final List<int> bytes = utf8.encode(await service.exportJson());
      final LibrarySnapshot restored = service.parseBytes(bytes);

      expect(
        restored.categories.map((Category c) => c.name),
        containsAll(<String>['Leer después', 'Diseño 🔥']),
      );
      expect(restored.cards.single.title, 'Añoranza, ñu y çedilla');
      expect(restored.cards.single.notes, 'Emoji 🔥 y comillas "así"');
    });
  });

  group('Archivos que no valen', () {
    test('un JSON corrupto no deja la base a medias', () async {
      await _fillLibrary(db, cards: 3, categories: 1);
      final int before = await DriftHelpers.linkRepository(
        db,
      ).watchCount().first;

      expect(() => service.parse('{esto no es json'), throwsA(anything));
      expect(
        () => service.parse('{"schemaVersion": 1}'),
        throwsA(isA<MalformedBackup>()),
      );

      expect(await DriftHelpers.linkRepository(db).watchCount().first, before);
    });

    test('un archivo de una versión futura se rechaza con claridad', () {
      expect(
        () => service.parse('{"schemaVersion": 99, "cards": [], "categories": []}'),
        throwsA(isA<UnsupportedSchemaVersion>()),
      );
    });

    test('ignora los campos que no conoce, para poder leer v2 desde v1', () {
      final LibrarySnapshot snapshot = service.parse(
        '{"schemaVersion": 1, "categories": [], "cards": ['
        '{"id":"a","url":"https://x.com/1","canonicalUrl":"https://x.com/1",'
        '"domain":"x.com","campoDelFuturo":{"algo":1}}]}',
      );

      expect(snapshot.cards.single.id, 'a');
    });
  });
}
