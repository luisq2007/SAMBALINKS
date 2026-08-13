import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Lo usa el código generado de app_database.g.dart, que es un `part` de este
// archivo y por tanto comparte sus imports.
import '../../features/links/domain/enums.dart';
import 'daos/cards_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/settings_dao.dart';
import 'tables/cards_table.dart';
import 'tables/categories_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[Cards, Categories, CardCategories, AppSettings],
  daos: <Type>[CardsDao, CategoriesDao, CardCategoriesDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'sambalinks'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (OpeningDetails details) async {
      // Drift NO activa las claves foráneas por defecto. Sin esto, el
      // ON DELETE CASCADE de card_categories es puramente decorativo y
      // borrar una categoría deja relaciones huérfanas.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
