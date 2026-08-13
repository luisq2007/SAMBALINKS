import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/daos/categories_dao.dart';
import '../../../core/result.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

extension on db.Category {
  Category toDomain() => Category(
    id: id,
    name: name,
    color: color,
    icon: icon,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(
    this._db, {
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _uuid = uuid,
       _now = now ?? (() => DateTime.now().toUtc());

  final db.AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Stream<List<Category>> watchAll() {
    return _db.categoriesDao.watchAll().map(
      (List<db.Category> rows) =>
          rows.map((db.Category r) => r.toDomain()).toList(),
    );
  }

  @override
  Stream<List<CategorySummary>> watchAllWithCounts() {
    return _db.categoriesDao.watchAllWithCounts().map(
      (List<CategoryWithCount> rows) => rows
          .map(
            (CategoryWithCount r) => CategorySummary(
              category: r.category.toDomain(),
              linkCount: r.count,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Category?> findById(String id) async =>
      (await _db.categoriesDao.findById(id))?.toDomain();

  @override
  Future<Result<Category>> create({
    required String name,
    String? color,
    String? icon,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Failure<Category>(
        ValidationFailure('El nombre no puede estar vacío'),
      );
    }

    final db.Category? existing = await _db.categoriesDao.findByName(trimmed);
    if (existing != null) {
      return Failure<Category>(
        DuplicateCategoryFailure(existingCategoryId: existing.id),
      );
    }

    final DateTime timestamp = _now();
    final Category category = Category(
      id: _uuid.v7(),
      name: trimmed,
      color: color,
      icon: icon,
      // Se añade al final de la lista existente.
      sortOrder: (await _db.categoriesDao.watchAll().first).length,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await _db.categoriesDao.upsert(_toCompanion(category));
    return Success<Category>(category);
  }

  @override
  Future<Category> update(Category category) async {
    final Category touched = category.copyWith(updatedAt: _now());
    await _db.categoriesDao.upsert(_toCompanion(touched));
    return touched;
  }

  @override
  Future<void> delete(String id) =>
      _db.categoriesDao.deleteById(id).then((_) {});

  @override
  Future<void> reorder(List<String> orderedIds) =>
      _db.categoriesDao.reorder(orderedIds);

  @override
  Stream<List<Category>> watchCategoriesOf(String cardId) {
    return _db.cardCategoriesDao
        .watchCategoriesOf(cardId)
        .map(
          (List<db.Category> rows) =>
              rows.map((db.Category r) => r.toDomain()).toList(),
        );
  }

  @override
  Future<void> assign({
    required String cardId,
    required String categoryId,
  }) => _db.cardCategoriesDao.assign(
    cardId: cardId,
    categoryId: categoryId,
    at: _now(),
  );

  @override
  Future<void> unassign({
    required String cardId,
    required String categoryId,
  }) => _db.cardCategoriesDao
      .unassign(cardId: cardId, categoryId: categoryId)
      .then((_) {});

  @override
  Future<void> setCategoriesOf(String cardId, Set<String> categoryIds) =>
      _db.cardCategoriesDao.setCategoriesOf(cardId, categoryIds);

  db.CategoriesCompanion _toCompanion(Category category) {
    return db.CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      color: Value<String?>(category.color),
      icon: Value<String?>(category.icon),
      sortOrder: Value<int>(category.sortOrder),
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
