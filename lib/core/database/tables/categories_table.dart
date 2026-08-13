import 'package:drift/drift.dart';

import 'cards_table.dart';

/// Categoría creada libremente por el usuario.
class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Hex de la paleta, p. ej. "#B9ECFA".
  TextColumn get color => text().nullable()();

  /// Clave de un catálogo propio de iconos ("lightbulb", "code"), **no** un
  /// codePoint de IconData: los codePoints rompen con el tree-shaking de
  /// iconos y no son portables entre versiones de Flutter, lo que arruinaría
  /// el JSON de exportación.
  TextColumn get icon => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{name},
  ];
}

/// Relación muchos-a-muchos entre enlaces y categorías (§14 del PRD).
///
/// Un enlace en tres categorías sigue siendo **un** registro en `cards`: por
/// eso "copiar a otra categoría" sólo crea una fila aquí.
@TableIndex(name: 'idx_cc_card', columns: <Symbol>{#cardId})
@TableIndex(name: 'idx_cc_category', columns: <Symbol>{#categoryId})
class CardCategories extends Table {
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();

  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{cardId, categoryId};
}

/// Preferencias de la aplicación. El valor se guarda como JSON.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
