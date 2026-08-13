import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/cards_table.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

/// Una categoría junto al número de enlaces que contiene.
class CategoryWithCount {
  const CategoryWithCount({required this.category, required this.count});

  final Category category;
  final int count;
}

@DriftAccessor(tables: <Type>[Categories, CardCategories, Cards])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() {
    return (select(categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) => OrderingTerm.asc(t.sortOrder),
            ($CategoriesTable t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  /// Categorías con su contador, para la barra lateral (§37).
  Stream<List<CategoryWithCount>> watchAllWithCounts() {
    final Expression<int> count = cardCategories.cardId.count();

    final JoinedSelectStatement<HasResultSet, dynamic> statement =
        select(categories).join(<Join<HasResultSet, dynamic>>[
            leftOuterJoin(
              cardCategories,
              cardCategories.categoryId.equalsExp(categories.id),
            ),
          ])
          ..addColumns(<Expression<Object>>[count])
          ..groupBy(<Expression<Object>>[categories.id])
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(categories.sortOrder),
            OrderingTerm.asc(categories.name),
          ]);

    return statement.watch().map(
      (List<TypedResult> rows) => rows
          .map(
            (TypedResult row) => CategoryWithCount(
              category: row.readTable(categories),
              count: row.read(count) ?? 0,
            ),
          )
          .toList(),
    );
  }

  Future<Category?> findById(String id) {
    return (select(
      categories,
    )..where(($CategoriesTable t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Category?> findByName(String name) {
    return (select(
      categories,
    )..where(($CategoriesTable t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<void> upsert(CategoriesCompanion category) =>
      into(categories).insertOnConflictUpdate(category);

  /// Borra la categoría y sus relaciones. **Nunca borra enlaces**: el CASCADE
  /// sólo alcanza a `card_categories`.
  Future<int> deleteById(String id) =>
      (delete(categories)..where(($CategoriesTable t) => t.id.equals(id))).go();

  Future<void> reorder(List<String> orderedIds) async {
    await batch((Batch batch) {
      for (int i = 0; i < orderedIds.length; i++) {
        batch.update(
          categories,
          CategoriesCompanion(sortOrder: Value<int>(i)),
          where: ($CategoriesTable t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }
}

@DriftAccessor(tables: <Type>[CardCategories, Categories])
class CardCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CardCategoriesDaoMixin {
  CardCategoriesDao(super.db);

  Stream<List<Category>> watchCategoriesOf(String cardId) {
    final JoinedSelectStatement<HasResultSet, dynamic> statement =
        select(cardCategories).join(<Join<HasResultSet, dynamic>>[
            innerJoin(
              categories,
              categories.id.equalsExp(cardCategories.categoryId),
            ),
          ])
          ..where(cardCategories.cardId.equals(cardId))
          ..orderBy(<OrderingTerm>[OrderingTerm.asc(categories.sortOrder)]);

    return statement.watch().map(
      (List<TypedResult> rows) =>
          rows.map((TypedResult r) => r.readTable(categories)).toList(),
    );
  }

  /// Añade el enlace a una categoría. Idempotente: repetirlo no duplica ni
  /// falla, que es lo que hace posible "añadir a otra categoría" sin
  /// comprobaciones previas en la UI.
  Future<void> assign({
    required String cardId,
    required String categoryId,
    DateTime? at,
  }) {
    return into(cardCategories).insert(
      CardCategoriesCompanion.insert(
        cardId: cardId,
        categoryId: categoryId,
        createdAt: at ?? DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<int> unassign({required String cardId, required String categoryId}) {
    return (delete(cardCategories)..where(
          ($CardCategoriesTable t) =>
              t.cardId.equals(cardId) & t.categoryId.equals(categoryId),
        ))
        .go();
  }

  Future<void> setCategoriesOf(String cardId, Set<String> categoryIds) async {
    await transaction(() async {
      await (delete(
        cardCategories,
      )..where(($CardCategoriesTable t) => t.cardId.equals(cardId))).go();

      final DateTime now = DateTime.now().toUtc();
      await batch((Batch batch) {
        batch.insertAll(cardCategories, <CardCategoriesCompanion>[
          for (final String id in categoryIds)
            CardCategoriesCompanion.insert(
              cardId: cardId,
              categoryId: id,
              createdAt: now,
            ),
        ], mode: InsertMode.insertOrIgnore);
      });
    });
  }
}
