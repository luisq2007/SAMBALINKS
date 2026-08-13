import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/core/database/daos/categories_dao.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_query.dart';

import 'database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  Future<List<String>> ids({
    CardFilter filter = const CardFilter(),
    CardSort sort = CardSort.newest,
  }) async {
    final List<Card> result = await db.cardsDao.getCards(
      filter: filter,
      sort: sort,
    );
    return result.map((Card c) => c.id).toList();
  }

  group('Filtros', () {
    setUp(() async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'ig-pendiente',
          canonicalUrl: 'https://instagram.com/p/1',
          domain: 'instagram.com',
          platform: LinkPlatform.instagram,
          status: CardStatus.pending,
          title: 'Onboarding de apps',
          imageUrl: 'https://cdn.example/1.jpg',
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      );
      await db.cardsDao.upsert(
        buildCard(
          id: 'yt-activo',
          canonicalUrl: 'https://youtube.com/watch?v=2',
          domain: 'youtube.com',
          platform: LinkPlatform.youtube,
          status: CardStatus.active,
          title: 'Animaciones en Flutter',
          notes: 'Ver el minuto 12',
          createdAt: DateTime.utc(2026, 8, 5),
        ),
      );
      await db.cardsDao.upsert(
        buildCard(
          id: 'ig-atendido',
          canonicalUrl: 'https://instagram.com/p/3',
          domain: 'instagram.com',
          platform: LinkPlatform.instagram,
          status: CardStatus.done,
          title: 'Paletas de color',
          createdAt: DateTime.utc(2026, 8, 10),
        ),
      );
    });

    test('sin filtro devuelve todo, del más reciente al más antiguo', () async {
      expect(await ids(), <String>['ig-atendido', 'yt-activo', 'ig-pendiente']);
    });

    test('por estado', () async {
      expect(
        await ids(
          filter: const CardFilter(statuses: <CardStatus>{CardStatus.active}),
        ),
        <String>['yt-activo'],
      );
    });

    test('por plataforma', () async {
      expect(
        await ids(
          filter: const CardFilter(
            platforms: <LinkPlatform>{LinkPlatform.instagram},
          ),
        ),
        <String>['ig-atendido', 'ig-pendiente'],
      );
    });

    test('estado y plataforma se combinan con AND', () async {
      expect(
        await ids(
          filter: const CardFilter(
            platforms: <LinkPlatform>{LinkPlatform.instagram},
            statuses: <CardStatus>{CardStatus.pending},
          ),
        ),
        <String>['ig-pendiente'],
      );
    });

    test('por rango de fechas', () async {
      expect(
        await ids(filter: CardFilter(createdAfter: DateTime.utc(2026, 8, 4))),
        <String>['ig-atendido', 'yt-activo'],
      );
    });

    test('con y sin imagen', () async {
      expect(await ids(filter: const CardFilter(hasImage: true)), <String>[
        'ig-pendiente',
      ]);
      expect(await ids(filter: const CardFilter(hasImage: false)), <String>[
        'ig-atendido',
        'yt-activo',
      ]);
    });

    test('con y sin notas', () async {
      expect(await ids(filter: const CardFilter(hasNotes: true)), <String>[
        'yt-activo',
      ]);
      expect(await ids(filter: const CardFilter(hasNotes: false)), <String>[
        'ig-atendido',
        'ig-pendiente',
      ]);
    });

    test('contador respeta el filtro', () async {
      expect(
        await db.cardsDao
            .watchCount(
              const CardFilter(
                platforms: <LinkPlatform>{LinkPlatform.instagram},
              ),
            )
            .first,
        2,
      );
    });

    test('contadores por estado cubren los tres, incluso con cero', () async {
      final Map<CardStatus, int> counts = await db.cardsDao
          .watchCountsByStatus()
          .first;
      expect(counts, <CardStatus, int>{
        CardStatus.pending: 1,
        CardStatus.active: 1,
        CardStatus.done: 1,
      });
    });
  });

  group('Búsqueda', () {
    setUp(() async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'c1',
          canonicalUrl: 'https://blog.dev/flutter-animaciones',
          domain: 'blog.dev',
          title: 'Animaciones fluidas',
          description: 'Cómo encadenar transiciones',
          notes: 'para el proyecto Trivali',
        ),
      );
      await db.cardsDao.upsert(
        buildCard(
          id: 'c2',
          canonicalUrl: 'https://noticias.com/economia',
          domain: 'noticias.com',
          title: 'Informe anual',
        ),
      );
    });

    test('encuentra por título, sin distinguir mayúsculas', () async {
      expect(
        await ids(filter: const CardFilter(query: 'ANIMACIONES')),
        <String>['c1'],
      );
    });

    test('encuentra por descripción', () async {
      expect(
        await ids(filter: const CardFilter(query: 'transiciones')),
        <String>['c1'],
      );
    });

    test('encuentra por notas', () async {
      expect(await ids(filter: const CardFilter(query: 'trivali')), <String>[
        'c1',
      ]);
    });

    test('encuentra por dominio', () async {
      expect(
        await ids(filter: const CardFilter(query: 'noticias.com')),
        <String>['c2'],
      );
    });

    test('encuentra por nombre de categoría', () async {
      await db.categoriesDao.upsert(
        buildCategory(id: 'cat-1', name: 'Marketing'),
      );
      await db.cardCategoriesDao.assign(cardId: 'c2', categoryId: 'cat-1');

      expect(await ids(filter: const CardFilter(query: 'marketing')), <String>[
        'c2',
      ]);
    });

    test('sin coincidencias devuelve lista vacía', () async {
      expect(await ids(filter: const CardFilter(query: 'zzz')), isEmpty);
    });
  });

  group('Bandeja', () {
    test('sólo muestra enlaces sin ninguna categoría', () async {
      await db.cardsDao.upsert(buildCard(id: 'sin-categoria'));
      await db.cardsDao.upsert(buildCard(id: 'con-categoria'));
      await db.categoriesDao.upsert(buildCategory(id: 'cat', name: 'Ideas'));
      await db.cardCategoriesDao.assign(
        cardId: 'con-categoria',
        categoryId: 'cat',
      );

      expect(await ids(filter: const CardFilter(uncategorized: true)), <String>[
        'sin-categoria',
      ]);
    });

    test('un enlace sale de la Bandeja al asignarle categoría', () async {
      await db.cardsDao.upsert(buildCard(id: 'c1'));
      await db.categoriesDao.upsert(buildCategory(id: 'cat', name: 'Ideas'));

      expect(await ids(filter: const CardFilter(uncategorized: true)), <String>[
        'c1',
      ]);

      await db.cardCategoriesDao.assign(cardId: 'c1', categoryId: 'cat');
      expect(await ids(filter: const CardFilter(uncategorized: true)), isEmpty);

      // Y vuelve a la Bandeja si se le quita.
      await db.cardCategoriesDao.unassign(cardId: 'c1', categoryId: 'cat');
      expect(await ids(filter: const CardFilter(uncategorized: true)), <String>[
        'c1',
      ]);
    });
  });

  group('Ordenación', () {
    setUp(() async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'b',
          canonicalUrl: 'https://b.com',
          title: 'Beta',
          platform: LinkPlatform.youtube,
          createdAt: DateTime.utc(2026, 8, 2),
          updatedAt: DateTime.utc(2026, 8, 20),
        ),
      );
      await db.cardsDao.upsert(
        buildCard(
          id: 'a',
          canonicalUrl: 'https://a.com',
          title: 'Alfa',
          platform: LinkPlatform.instagram,
          createdAt: DateTime.utc(2026, 8, 9),
          updatedAt: DateTime.utc(2026, 8, 9),
        ),
      );
    });

    test('más recientes primero es el orden por defecto', () async {
      expect(await ids(), <String>['a', 'b']);
    });

    test('más antiguos primero', () async {
      expect(await ids(sort: CardSort.oldest), <String>['b', 'a']);
    });

    test('actualizados recientemente', () async {
      expect(await ids(sort: CardSort.recentlyUpdated), <String>['b', 'a']);
    });

    test('título A-Z y Z-A', () async {
      expect(await ids(sort: CardSort.titleAsc), <String>['a', 'b']);
      expect(await ids(sort: CardSort.titleDesc), <String>['b', 'a']);
    });

    test('por plataforma', () async {
      expect(await ids(sort: CardSort.platform), <String>['a', 'b']);
    });

    test('por estado', () async {
      await db.cardsDao.upsert(
        buildCard(
          id: 'c',
          canonicalUrl: 'https://c.com',
          title: 'Gamma',
          status: CardStatus.active,
          createdAt: DateTime.utc(2026, 8, 3),
        ),
      );
      expect(await ids(sort: CardSort.status), <String>['c', 'a', 'b']);
    });
  });

  group('Escala y paginación de la Vista Lista', () {
    test('2.000 cards responden a búsqueda en menos de 150 ms', () async {
      await db.batch((Batch batch) {
        for (int index = 0; index < 2000; index++) {
          batch.insert(
            db.cards,
            buildCard(
              id: 'scale-${index.toString().padLeft(4, '0')}',
              canonicalUrl: 'https://scale.example/$index',
              domain: 'scale.example',
              title: index == 1742
                  ? 'Aguja medible del benchmark'
                  : 'Enlace de escala $index',
              notes: index.isEven ? 'nota par' : null,
              status: CardStatus.values[index % CardStatus.values.length],
              platform: LinkPlatform.values[index % LinkPlatform.values.length],
              createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: index)),
            ),
          );
        }
      });

      // Calienta el statement para que la medida represente la interacción y
      // no la inicialización de SQLite en el proceso de test.
      await db.cardsDao.getCards(
        filter: const CardFilter(query: 'calentamiento'),
        limit: 40,
      );
      final Stopwatch stopwatch = Stopwatch()..start();
      final List<Card> result = await db.cardsDao.getCards(
        filter: const CardFilter(query: 'aguja medible'),
        limit: 40,
      );
      stopwatch.stop();

      expect(result.map((Card card) => card.id), <String>['scale-1742']);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(150),
        reason: 'La búsqueda tardó ${stopwatch.elapsedMilliseconds} ms.',
      );
    });

    test('páginas estables no repiten ni omiten ids empatados', () async {
      final DateTime sameTime = DateTime.utc(2026, 8, 12);
      await db.batch((Batch batch) {
        for (int index = 0; index < 100; index++) {
          batch.insert(
            db.cards,
            buildCard(
              id: 'tie-${index.toString().padLeft(3, '0')}',
              canonicalUrl: 'https://ties.example/$index',
              createdAt: sameTime,
              updatedAt: sameTime,
              title: 'Mismo título',
            ),
          );
        }
      });

      final List<Card> allPages = <Card>[];
      for (int offset = 0; offset < 100; offset += 40) {
        allPages.addAll(
          await db.cardsDao.getCards(
            sort: CardSort.titleAsc,
            limit: 40,
            offset: offset,
          ),
        );
      }

      expect(allPages, hasLength(100));
      expect(allPages.map((Card card) => card.id).toSet(), hasLength(100));
    });

    test(
      'filtros combinados coinciden con una consulta SQL de referencia',
      () async {
        await db.cardsDao.upsert(
          buildCard(
            id: 'match',
            canonicalUrl: 'https://instagram.com/p/match',
            domain: 'instagram.com',
            title: 'Diseño aguja',
            notes: 'guardar aguja',
            imageUrl: 'https://cdn.example/match.jpg',
            status: CardStatus.active,
            platform: LinkPlatform.instagram,
          ),
        );
        await db.cardsDao.upsert(
          buildCard(
            id: 'wrong-status',
            canonicalUrl: 'https://instagram.com/p/status',
            title: 'Diseño aguja',
            notes: 'guardar aguja',
            imageUrl: 'https://cdn.example/status.jpg',
            status: CardStatus.pending,
            platform: LinkPlatform.instagram,
          ),
        );
        await db.cardsDao.upsert(
          buildCard(
            id: 'wrong-notes',
            canonicalUrl: 'https://instagram.com/p/notes',
            title: 'Diseño aguja',
            imageUrl: 'https://cdn.example/notes.jpg',
            status: CardStatus.active,
            platform: LinkPlatform.instagram,
          ),
        );

        const CardFilter filter = CardFilter(
          statuses: <CardStatus>{CardStatus.active},
          platforms: <LinkPlatform>{LinkPlatform.instagram},
          hasImage: true,
          hasNotes: true,
          query: 'aguja',
        );
        final Set<String> actual = (await db.cardsDao.getCards(
          filter: filter,
        )).map((Card card) => card.id).toSet();
        final List<QueryRow> referenceRows = await db.customSelect('''
        SELECT id FROM cards
        WHERE status = 'active'
          AND platform = 'instagram'
          AND (image_url IS NOT NULL OR local_image IS NOT NULL)
          AND notes IS NOT NULL AND trim(notes) <> ''
          AND (
            lower(title) LIKE '%aguja%'
            OR lower(description) LIKE '%aguja%'
            OR lower(domain) LIKE '%aguja%'
            OR lower(url) LIKE '%aguja%'
            OR lower(notes) LIKE '%aguja%'
            OR lower(platform) LIKE '%aguja%'
          )
        ''').get();
        final Set<String> reference = <String>{
          for (final QueryRow row in referenceRows) row.read<String>('id'),
        };

        expect(actual, reference);
        expect(actual, <String>{'match'});
      },
    );
  });

  group('Relación muchos-a-muchos', () {
    test(
      'el mismo enlace en dos categorías sigue siendo un único registro',
      () async {
        // Criterios 8 y 9 de §55 del PRD.
        await db.cardsDao.upsert(buildCard(id: 'card-1'));
        await db.categoriesDao.upsert(
          buildCategory(id: 'ideas', name: 'Ideas'),
        );
        await db.categoriesDao.upsert(
          buildCategory(id: 'trivali', name: 'Trivali'),
        );

        await db.cardCategoriesDao.assign(
          cardId: 'card-1',
          categoryId: 'ideas',
        );
        await db.cardCategoriesDao.assign(
          cardId: 'card-1',
          categoryId: 'trivali',
        );

        expect(await db.select(db.cards).get(), hasLength(1));
        expect(await db.select(db.cardCategories).get(), hasLength(2));

        // Y al listar filtrando por ambas categorías aparece una sola vez.
        expect(
          await ids(
            filter: const CardFilter(categoryIds: <String>{'ideas', 'trivali'}),
          ),
          <String>['card-1'],
        );
      },
    );

    test('asignar dos veces la misma categoría es idempotente', () async {
      await db.cardsDao.upsert(buildCard(id: 'card-1'));
      await db.categoriesDao.upsert(buildCategory(id: 'cat', name: 'Ideas'));

      await db.cardCategoriesDao.assign(cardId: 'card-1', categoryId: 'cat');
      await db.cardCategoriesDao.assign(cardId: 'card-1', categoryId: 'cat');

      expect(await db.select(db.cardCategories).get(), hasLength(1));
    });

    test('setCategoriesOf reemplaza el conjunto completo', () async {
      await db.cardsDao.upsert(buildCard(id: 'card-1'));
      for (final String name in <String>['a', 'b', 'c']) {
        await db.categoriesDao.upsert(buildCategory(id: name, name: name));
      }
      await db.cardCategoriesDao.setCategoriesOf('card-1', <String>{'a', 'b'});
      await db.cardCategoriesDao.setCategoriesOf('card-1', <String>{'b', 'c'});

      final List<Category> result = await db.cardCategoriesDao
          .watchCategoriesOf('card-1')
          .first;
      expect(result.map((Category c) => c.id).toSet(), <String>{'b', 'c'});
    });

    test('el contador por categoría incluye las vacías con cero', () async {
      await db.cardsDao.upsert(buildCard(id: 'card-1'));
      await db.categoriesDao.upsert(buildCategory(id: 'con', name: 'Con'));
      await db.categoriesDao.upsert(buildCategory(id: 'sin', name: 'Sin'));
      await db.cardCategoriesDao.assign(cardId: 'card-1', categoryId: 'con');

      final List<CategoryWithCount> counts = await db.categoriesDao
          .watchAllWithCounts()
          .first;

      expect(
        <String, int>{
          for (final CategoryWithCount c in counts) c.category.id: c.count,
        },
        <String, int>{'con': 1, 'sin': 0},
      );
    });
  });

  group('Reactividad', () {
    test('la lista emite de nuevo cuando cambia un enlace', () async {
      final List<List<Card>> emissions = <List<Card>>[];
      final StreamSubscription<List<Card>> subscription = db.cardsDao
          .watchCards()
          .listen(emissions.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      expect(emissions, hasLength(1));
      expect(emissions.single, isEmpty);

      await db.cardsDao.upsert(buildCard(id: 'c1'));
      await pumpEventQueue();

      expect(emissions.length, greaterThan(1));
      expect(emissions.last, hasLength(1));
    });
  });
}
