import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'settings_dao.g.dart';

/// Preferencias como pares clave/valor con el valor serializado en JSON.
///
/// Vive en la base de datos y no en `shared_preferences` porque el JSON
/// portable (§29 del PRD) debe llevarse los ajustes junto con los datos.
@DriftAccessor(tables: <Type>[AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<T?> read<T>(String key) async {
    final AppSetting? row = await (select(
      appSettings,
    )..where(($AppSettingsTable t) => t.key.equals(key))).getSingleOrNull();

    if (row == null) {
      return null;
    }
    final Object? decoded = jsonDecode(row.value);
    return decoded is T ? decoded : null;
  }

  Stream<T?> watch<T>(String key) {
    return (select(appSettings)..where(($AppSettingsTable t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((AppSetting? row) {
          if (row == null) {
            return null;
          }
          final Object? decoded = jsonDecode(row.value);
          return decoded is T ? decoded : null;
        });
  }

  Future<void> write(String key, Object? value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: jsonEncode(value)),
    );
  }

  Future<Map<String, Object?>> readAll() async {
    final List<AppSetting> rows = await select(appSettings).get();
    return <String, Object?>{
      for (final AppSetting row in rows) row.key: jsonDecode(row.value),
    };
  }

  Future<int> remove(String key) =>
      (delete(appSettings)..where(($AppSettingsTable t) => t.key.equals(key))).go();
}

/// Claves de ajustes conocidas. Centralizadas para que el exportador y el
/// importador no dependan de literales sueltos.
abstract final class SettingsKeys {
  static const String theme = 'theme';
  static const String defaultView = 'defaultView';
  static const String defaultSort = 'defaultSort';
  static const String seedCompleted = 'seedCompleted';
}
