import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/database/daos/settings_dao.dart';
import 'package:sambalinks/core/database/seed.dart';
import 'package:sambalinks/core/result.dart';
import 'package:sambalinks/features/categories/data/drift_category_repository.dart';
import 'package:sambalinks/features/categories/domain/category.dart';
import 'package:sambalinks/features/categories/domain/category_repository.dart';
import 'package:sambalinks/features/links/data/drift_link_repository.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_query.dart';

import '../core/database/database_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DriftLinkRepository links;
  late CategoryRepository categories;

  setUp(() {
    db = openTestDatabase();
    links = DriftLinkRepository(db);
    categories = DriftCategoryRepository(db);
  });
  tearDown(() => db.close());

  LinkCard makeCard({
    required String id,
    required String canonicalUrl,
    String domain = 'ejemplo.com',
    String? title,
    CardStatus status = CardStatus.pending,
  }) {
    final DateTime now = DateTime.utc(2026, 8, 12);
    return LinkCard(
      id: id,
      url: canonicalUrl,
      canonicalUrl: canonicalUrl,
      domain: domain,
      title: title,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('LinkRepository', () {
    test('crea y recupera un enlace', () async {
      final LinkCard card = makeCard(
        id: 'c1',
        canonicalUrl: 'https://ejemplo.com/a',
        title: 'Un artículo',
      );

      final Result<LinkCard> result = await links.create(card);

      expect(result.isSuccess, isTrue);
      final LinkCard? stored = await links.findById('c1');
      expect(stored!.title, 'Un artículo');
      expect(stored.status, CardStatus.pending);
    });

    test(
      'crear un duplicado devuelve el id del existente en lugar de lanzar',
      () async {
        // §27: compartir dos veces el mismo post es un caso esperado. La UI
        // necesita el id para ofrecer "Abrir card".
        await links.create(
          makeCard(id: 'original', canonicalUrl: 'https://instagram.com/p/ABC'),
        );

        final Result<LinkCard> result = await links.create(
          makeCard(id: 'nuevo', canonicalUrl: 'https://instagram.com/p/ABC'),
        );

        expect(result.isSuccess, isFalse);
        final AppFailure? failure = result.failureOrNull;
        expect(failure, isA<DuplicateLinkFailure>());
        expect((failure! as DuplicateLinkFailure).existingCardId, 'original');

        // Y no se ha creado nada.
        expect(await links.findById('nuevo'), isNull);
      },
    );

    test('update refresca updatedAt pero conserva createdAt', () async {
      final LinkCard card = makeCard(id: 'c1', canonicalUrl: 'https://a.com');
      await links.create(card);

      final LinkCard updated = await links.update(
        card.copyWith(title: 'Nuevo título'),
      );

      expect(updated.title, 'Nuevo título');
      expect(updated.createdAt, card.createdAt);
      expect(updated.updatedAt.isAfter(card.updatedAt), isTrue);
    });

    test('updateStatus no toca notas ni categorías', () async {
      await links.create(
        makeCard(id: 'c1', canonicalUrl: 'https://a.com').copyWith(
          notes: 'no me borres',
        ),
      );
      final Result<Category> cat = await categories.create(name: 'Ideas');
      await categories.assign(
        cardId: 'c1',
        categoryId: cat.valueOrNull!.id,
      );

      await links.updateStatus('c1', CardStatus.done);

      final LinkCard? card = await links.findById('c1');
      expect(card!.status, CardStatus.done);
      expect(card.notes, 'no me borres');
      expect(await categories.watchCategoriesOf('c1').first, hasLength(1));
    });

    test('displayTitle cae al dominio cuando no hay título', () async {
      final LinkCard card = makeCard(
        id: 'c1',
        canonicalUrl: 'https://instagram.com/p/x',
        domain: 'instagram.com',
      );
      expect(card.displayTitle, 'instagram.com');
      expect(card.copyWith(title: '  ').displayTitle, 'instagram.com');
      expect(card.copyWith(title: 'Real').displayTitle, 'Real');
    });

    test('la lista filtrada llega como entidades de dominio', () async {
      await links.create(
        makeCard(
          id: 'c1',
          canonicalUrl: 'https://a.com',
          status: CardStatus.active,
        ),
      );
      await links.create(
        makeCard(id: 'c2', canonicalUrl: 'https://b.com'),
      );

      final List<LinkCard> active = await links
          .watchLinks(
            filter: const CardFilter(statuses: <CardStatus>{CardStatus.active}),
          )
          .first;

      expect(active, hasLength(1));
      expect(active.single.id, 'c1');
    });
  });

  group('CategoryRepository', () {
    test('crea una categoría y la coloca al final', () async {
      final Result<Category> first = await categories.create(name: 'Ideas');
      final Result<Category> second = await categories.create(name: 'Flutter');

      expect(first.valueOrNull!.sortOrder, 0);
      expect(second.valueOrNull!.sortOrder, 1);
    });

    test('recorta el nombre y rechaza el vacío', () async {
      final Result<Category> ok = await categories.create(name: '  Ideas  ');
      expect(ok.valueOrNull!.name, 'Ideas');

      final Result<Category> empty = await categories.create(name: '   ');
      expect(empty.failureOrNull, isA<ValidationFailure>());
    });

    test('un nombre repetido devuelve el id de la existente', () async {
      final Result<Category> first = await categories.create(name: 'Ideas');
      final Result<Category> repeat = await categories.create(name: 'Ideas');

      expect(repeat.failureOrNull, isA<DuplicateCategoryFailure>());
      expect(
        (repeat.failureOrNull! as DuplicateCategoryFailure).existingCategoryId,
        first.valueOrNull!.id,
      );
    });

    test('borrar una categoría no borra sus enlaces', () async {
      await links.create(makeCard(id: 'c1', canonicalUrl: 'https://a.com'));
      final Category cat = (await categories.create(name: 'Ideas')).valueOrNull!;
      await categories.assign(cardId: 'c1', categoryId: cat.id);

      await categories.delete(cat.id);

      expect(await links.findById('c1'), isNotNull);
      expect(await categories.watchCategoriesOf('c1').first, isEmpty);
    });

    test('el contador de la barra lateral incluye categorías vacías', () async {
      await links.create(makeCard(id: 'c1', canonicalUrl: 'https://a.com'));
      final Category con = (await categories.create(name: 'Con')).valueOrNull!;
      await categories.create(name: 'Sin');
      await categories.assign(cardId: 'c1', categoryId: con.id);

      final List<CategorySummary> summaries = await categories
          .watchAllWithCounts()
          .first;

      expect(<String, int>{
        for (final CategorySummary s in summaries)
          s.category.name: s.linkCount,
      }, <String, int>{'Con': 1, 'Sin': 0});
    });

    test('reordenar persiste el nuevo orden', () async {
      final Category a = (await categories.create(name: 'A')).valueOrNull!;
      final Category b = (await categories.create(name: 'B')).valueOrNull!;
      final Category c = (await categories.create(name: 'C')).valueOrNull!;

      await categories.reorder(<String>[c.id, a.id, b.id]);

      final List<Category> ordered = await categories.watchAll().first;
      expect(
        ordered.map((Category x) => x.name).toList(),
        <String>['C', 'A', 'B'],
      );
    });
  });

  group('Datos semilla', () {
    test('crea las categorías de ejemplo en el primer arranque', () async {
      await seedIfNeeded(categories: categories, settings: db.settingsDao);

      final List<Category> result = await categories.watchAll().first;
      expect(
        result.map((Category c) => c.name).toList(),
        <String>['Leer después', 'Inspiración', 'Ideas'],
      );
    });

    test('no las recrea en arranques posteriores', () async {
      await seedIfNeeded(categories: categories, settings: db.settingsDao);
      await seedIfNeeded(categories: categories, settings: db.settingsDao);

      expect(await categories.watchAll().first, hasLength(3));
    });

    test(
      'si el usuario borra todas las de ejemplo, no reaparecen',
      () async {
        await seedIfNeeded(categories: categories, settings: db.settingsDao);
        for (final Category c in await categories.watchAll().first) {
          await categories.delete(c.id);
        }

        await seedIfNeeded(categories: categories, settings: db.settingsDao);

        expect(await categories.watchAll().first, isEmpty);
      },
    );
  });

  group('SettingsDao', () {
    test('guarda y lee valores tipados', () async {
      await db.settingsDao.write(SettingsKeys.theme, 'dark');
      await db.settingsDao.write(SettingsKeys.defaultSort, 'newest');

      expect(await db.settingsDao.read<String>(SettingsKeys.theme), 'dark');
      expect(await db.settingsDao.readAll(), <String, Object?>{
        SettingsKeys.theme: 'dark',
        SettingsKeys.defaultSort: 'newest',
      });
    });

    test('una clave inexistente devuelve null', () async {
      expect(await db.settingsDao.read<String>('no-existe'), isNull);
    });

    test('escribir dos veces la misma clave la reemplaza', () async {
      await db.settingsDao.write(SettingsKeys.theme, 'dark');
      await db.settingsDao.write(SettingsKeys.theme, 'light');

      expect(await db.settingsDao.read<String>(SettingsKeys.theme), 'light');
    });
  });
}
