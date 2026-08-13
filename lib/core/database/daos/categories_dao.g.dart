// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $CardsTable get cards => attachedDatabase.cards;
  $CardCategoriesTable get cardCategories => attachedDatabase.cardCategories;
  CategoriesDaoManager get managers => CategoriesDaoManager(this);
}

class CategoriesDaoManager {
  final _$CategoriesDaoMixin _db;
  CategoriesDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$CardCategoriesTableTableManager get cardCategories =>
      $$CardCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.cardCategories,
      );
}

mixin _$CardCategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardsTable get cards => attachedDatabase.cards;
  $CategoriesTable get categories => attachedDatabase.categories;
  $CardCategoriesTable get cardCategories => attachedDatabase.cardCategories;
  CardCategoriesDaoManager get managers => CardCategoriesDaoManager(this);
}

class CardCategoriesDaoManager {
  final _$CardCategoriesDaoMixin _db;
  CardCategoriesDaoManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$CardCategoriesTableTableManager get cardCategories =>
      $$CardCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.cardCategories,
      );
}
