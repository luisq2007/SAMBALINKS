import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/daos/settings_dao.dart';
import '../../categories/domain/category.dart';
import '../../links/data/link_card_mapper.dart';
import '../../links/domain/link_card.dart';
import '../domain/library_snapshot.dart';

/// Qué hacer con la biblioteca actual al importar (§30 del PRD).
enum ImportMode {
  /// Añade lo importado a lo que ya hay.
  merge,

  /// Borra todo y deja sólo lo importado.
  replace,
}

/// Qué hacer cuando un enlace importado ya existe (§30).
enum DuplicatePolicy {
  /// No se toca el que ya está.
  keepExisting,

  /// El importado gana.
  replaceWithImported,

  /// Gana el que tenga `updatedAt` más reciente.
  keepNewest,
}

class ImportReport {
  const ImportReport({
    required this.cardsAdded,
    required this.cardsUpdated,
    required this.cardsSkipped,
    required this.categoriesAdded,
    required this.relationsAdded,
  });

  final int cardsAdded;
  final int cardsUpdated;
  final int cardsSkipped;
  final int categoriesAdded;
  final int relationsAdded;
}

/// Exporta e importa la biblioteca completa en JSON portable.
class LibraryBackupService {
  LibraryBackupService(this._db, {String? appVersion})
    : _appVersion = appVersion;

  final db.AppDatabase _db;
  final String? _appVersion;

  // --- Exportar ---

  Future<LibrarySnapshot> snapshot() async {
    final List<db.Card> cards = await _db.select(_db.cards).get();
    final List<db.Category> categories = await _db.select(_db.categories).get();
    final List<db.CardCategory> relations = await _db
        .select(_db.cardCategories)
        .get();

    return LibrarySnapshot(
      appVersion: _appVersion,
      exportedAt: DateTime.now().toUtc(),
      settings: await _db.settingsDao.readAll(),
      cards: cards.map((db.Card c) => c.toDomain()).toList(),
      categories: <Category>[
        for (final db.Category c in categories)
          Category(
            id: c.id,
            name: c.name,
            color: c.color,
            icon: c.icon,
            sortOrder: c.sortOrder,
            createdAt: c.createdAt,
            updatedAt: c.updatedAt,
          ),
      ],
      relations: <SnapshotRelation>[
        for (final db.CardCategory r in relations)
          SnapshotRelation(
            cardId: r.cardId,
            categoryId: r.categoryId,
            createdAt: r.createdAt,
          ),
      ],
    );
  }

  /// JSON con sangrado: un backup se abre a veces con un editor de texto y
  /// una sola línea de 2 MB no hay quien la lea.
  Future<String> exportJson() async {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert((await snapshot()).toJson());
  }

  /// Borra enlaces y categorías. **No** toca los ajustes: el tema elegido no
  /// es parte de la biblioteca.
  Future<void> clearLibrary() async {
    await _db.transaction(() async {
      // El CASCADE se lleva las relaciones.
      await _db.delete(_db.cards).go();
      await _db.delete(_db.categories).go();
    });
  }

  // --- Importar ---

  /// Igual que [parse] pero desde los bytes del archivo, **decodificando UTF-8
  /// de forma explícita**.
  ///
  /// No dar por hecha la codificación: leyendo el archivo como texto sin
  /// especificarla, los acentos llegaban rotos ("Leer despuÃ©s") porque los
  /// bytes UTF-8 se interpretaban como Latin-1. Un backup con la mitad de los
  /// nombres corruptos es peor que uno que falla.
  LibrarySnapshot parseBytes(List<int> bytes) =>
      parse(const Utf8Decoder().convert(bytes));

  /// Lee y valida sin tocar la base, para poder enseñar el recuento antes de
  /// pedir confirmación.
  LibrarySnapshot parse(String json) {
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      throw const MalformedBackup();
    }
    return LibrarySnapshot.fromJson(decoded);
  }

  /// Aplica [snapshot] **en una transacción**: o entra todo, o no entra nada.
  /// Una importación a medias es peor que ninguna.
  Future<ImportReport> import(
    LibrarySnapshot snapshot, {
    ImportMode mode = ImportMode.merge,
    DuplicatePolicy duplicates = DuplicatePolicy.keepExisting,
  }) async {
    int added = 0;
    int updated = 0;
    int skipped = 0;
    int categoriesAdded = 0;
    int relationsAdded = 0;

    await _db.transaction(() async {
      if (mode == ImportMode.replace) {
        // El CASCADE se lleva las relaciones.
        await _db.delete(_db.cards).go();
        await _db.delete(_db.categories).go();
      }

      // Las categorías se resuelven por nombre: dos bibliotecas distintas usan
      // ids distintos para "Ideas", y fusionarlas por id crearía duplicados
      // visibles para el usuario.
      final Map<String, String> categoryIdMap = <String, String>{};
      for (final Category incoming in snapshot.categories) {
        final db.Category? existing = await _db.categoriesDao.findByName(
          incoming.name,
        );
        if (existing != null) {
          categoryIdMap[incoming.id] = existing.id;
          continue;
        }
        await _db.categoriesDao.upsert(
          db.CategoriesCompanion.insert(
            id: incoming.id,
            name: incoming.name,
            color: Value<String?>(incoming.color),
            icon: Value<String?>(incoming.icon),
            sortOrder: Value<int>(incoming.sortOrder),
            createdAt: incoming.createdAt,
            updatedAt: incoming.updatedAt,
          ),
        );
        categoryIdMap[incoming.id] = incoming.id;
        categoriesAdded++;
      }

      final Map<String, String> cardIdMap = <String, String>{};
      for (final LinkCard incoming in snapshot.cards) {
        final db.Card? existing = await _db.cardsDao.findByCanonicalUrl(
          incoming.canonicalUrl,
        );

        if (existing == null) {
          await _db.cardsDao.upsert(incoming.toCompanion());
          cardIdMap[incoming.id] = incoming.id;
          added++;
          continue;
        }

        cardIdMap[incoming.id] = existing.id;
        final bool overwrite = switch (duplicates) {
          DuplicatePolicy.keepExisting => false,
          DuplicatePolicy.replaceWithImported => true,
          DuplicatePolicy.keepNewest => incoming.updatedAt.isAfter(
            existing.updatedAt,
          ),
        };

        if (overwrite) {
          // Se conserva el id que ya estaba para no romper las relaciones que
          // el usuario tuviera hechas con ese enlace.
          await _db.cardsDao.upsert(
            incoming.copyWith(id: existing.id).toCompanion(),
          );
          updated++;
        } else {
          skipped++;
        }
      }

      for (final SnapshotRelation relation in snapshot.relations) {
        final String? cardId = cardIdMap[relation.cardId];
        final String? categoryId = categoryIdMap[relation.categoryId];
        if (cardId == null || categoryId == null) {
          continue;
        }
        await _db.cardCategoriesDao.assign(
          cardId: cardId,
          categoryId: categoryId,
          at: relation.createdAt,
        );
        relationsAdded++;
      }

      for (final MapEntry<String, Object?> entry in snapshot.settings.entries) {
        // La marca de la semilla no viaja: es un detalle de este dispositivo.
        if (entry.key == SettingsKeys.seedCompleted) {
          continue;
        }
        await _db.settingsDao.write(entry.key, entry.value);
      }
    });

    return ImportReport(
      cardsAdded: added,
      cardsUpdated: updated,
      cardsSkipped: skipped,
      categoriesAdded: categoriesAdded,
      relationsAdded: relationsAdded,
    );
  }
}
