// drift exporta matchers homónimos a los de flutter_test (isNotNull, isNull).
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:uuid/uuid.dart';

import 'database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  group('Integridad del esquema', () {
    test('las claves foráneas están activas', () async {
      // Sin PRAGMA foreign_keys = ON el CASCADE es decorativo. Esta es la
      // comprobación que evita que ese fallo pase inadvertido.
      final QueryRow row = await db
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(row.data.values.first, 1);
    });

    test('canonical_url es UNIQUE y rechaza el duplicado', () async {
      await db.cardsDao.upsert(
        buildCard(canonicalUrl: 'https://instagram.com/p/ABC'),
      );

      expect(
        () => db.into(db.cards).insert(
          buildCard(canonicalUrl: 'https://instagram.com/p/ABC'),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('el nombre de categoría es UNIQUE', () async {
      await db.categoriesDao.upsert(buildCategory(name: 'Inspiración'));

      expect(
        () => db.into(db.categories).insert(buildCategory(name: 'Inspiración')),
        throwsA(isA<SqliteException>()),
      );
    });

    test('los índices de §46 del PRD existen', () async {
      final List<QueryRow> rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'idx_%'",
          )
          .get();
      final Set<String> names = rows
          .map((QueryRow r) => r.read<String>('name'))
          .toSet();

      expect(names, <String>{
        'idx_cards_created_at',
        'idx_cards_updated_at',
        'idx_cards_status',
        'idx_cards_platform',
        'idx_cards_domain',
        'idx_cc_card',
        'idx_cc_category',
      });
    });
  });

  group('Persistencia de enums', () {
    test('se guardan como texto legible, no como índice ordinal', () async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'card-1',
          status: CardStatus.active,
          platform: LinkPlatform.instagram,
        ),
      );

      final QueryRow row = await db
          .customSelect("SELECT status, platform FROM cards WHERE id = 'card-1'")
          .getSingle();

      expect(row.read<String>('status'), 'active');
      expect(row.read<String>('platform'), 'instagram');
    });

    test('un valor desconocido en la base no rompe la lectura', () async {
      // Escenario real: una versión futura introduce un estado propio (§12) y
      // el usuario abre esa biblioteca con una versión anterior.
      await db.cardsDao.upsert(buildCard(id: 'card-1'));
      await db.customStatement(
        "UPDATE cards SET status = 'archivado' WHERE id = 'card-1'",
      );

      final Card? card = await db.cardsDao.findById('card-1');
      expect(card!.status, CardStatus.pending);
    });
  });

  group('Borrado en cascada', () {
    test('borrar un enlace elimina sus relaciones', () async {
      const Uuid uuid = Uuid();
      final String cardId = uuid.v7();
      final String categoryId = uuid.v7();

      await db.cardsDao.upsert(buildCard(id: cardId));
      await db.categoriesDao.upsert(
        buildCategory(id: categoryId, name: 'Ideas'),
      );
      await db.cardCategoriesDao.assign(
        cardId: cardId,
        categoryId: categoryId,
      );

      await db.cardsDao.deleteById(cardId);

      final List<CardCategory> relations = await db
          .select(db.cardCategories)
          .get();
      expect(relations, isEmpty);
    });

    test('borrar una categoría elimina relaciones pero NO enlaces', () async {
      const Uuid uuid = Uuid();
      final String cardId = uuid.v7();
      final String categoryId = uuid.v7();

      await db.cardsDao.upsert(buildCard(id: cardId));
      await db.categoriesDao.upsert(
        buildCategory(id: categoryId, name: 'Marketing'),
      );
      await db.cardCategoriesDao.assign(
        cardId: cardId,
        categoryId: categoryId,
      );

      await db.categoriesDao.deleteById(categoryId);

      expect(await db.select(db.cardCategories).get(), isEmpty);
      expect(await db.cardsDao.findById(cardId), isNotNull);
    });
  });

  group('Migraciones', () {
    test('la base se crea en la versión 1', () async {
      await db.cardsDao.upsert(buildCard());
      expect(db.schemaVersion, 1);
    });
  });
}
