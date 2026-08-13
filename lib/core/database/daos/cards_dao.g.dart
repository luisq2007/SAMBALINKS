// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_dao.dart';

// ignore_for_file: type=lint
mixin _$CardsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardsTable get cards => attachedDatabase.cards;
  $CategoriesTable get categories => attachedDatabase.categories;
  $CardCategoriesTable get cardCategories => attachedDatabase.cardCategories;
  CardsDaoManager get managers => CardsDaoManager(this);
}

class CardsDaoManager {
  final _$CardsDaoMixin _db;
  CardsDaoManager(this._db);
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
