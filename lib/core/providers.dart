import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/categories/data/drift_category_repository.dart';
import '../features/categories/domain/category.dart';
import '../features/categories/domain/category_repository.dart';
import '../features/links/data/drift_link_repository.dart';
import '../features/links/domain/enums.dart';
import '../features/links/domain/link_card.dart';
import '../features/links/domain/link_query.dart';
import '../features/links/domain/link_repository.dart';
// Se oculta Category: Drift genera una homónima y aquí manda la del dominio.
import 'database/app_database.dart' hide Category;
import 'database/daos/settings_dao.dart';
import 'database/seed.dart';

/// Providers de la aplicación.
///
/// Se declaran a mano en lugar de con `riverpod_generator` porque éste exige
/// una versión de `analyzer` incompatible con `drift_dev` en Flutter 3.41.6
/// (ver docs/entorno-desarrollo.md). La API manual es equivalente.

// --- Infraestructura ---

/// Instancia única de la base de datos.
///
/// En los tests se sobreescribe con una base en memoria mediante
/// `overrideWithValue`.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((
  Ref ref,
) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<SettingsDao> settingsDaoProvider = Provider<SettingsDao>(
  (Ref ref) => ref.watch(databaseProvider).settingsDao,
);

// --- Repositorios ---

final Provider<LinkRepository> linkRepositoryProvider = Provider<LinkRepository>(
  (Ref ref) => DriftLinkRepository(ref.watch(databaseProvider)),
);

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>(
      (Ref ref) => DriftCategoryRepository(ref.watch(databaseProvider)),
    );

// --- Consultas de enlaces ---

/// Parámetros de una consulta de enlaces. Es el argumento de familia, así que
/// necesita igualdad por valor para no recrear el provider en cada rebuild.
class LinkQuery {
  const LinkQuery({
    this.filter = const CardFilter(),
    this.sort = CardSort.newest,
    this.limit,
    this.offset = 0,
  });

  final CardFilter filter;
  final CardSort sort;
  final int? limit;
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkQuery &&
          other.sort == sort &&
          other.limit == limit &&
          other.offset == offset &&
          _sameFilter(other.filter, filter);

  @override
  int get hashCode => Object.hash(
    sort,
    limit,
    offset,
    filter.uncategorized,
    filter.query,
    filter.hasImage,
    filter.hasNotes,
    filter.createdAfter,
    filter.createdBefore,
    Object.hashAllUnordered(filter.statuses ?? const <CardStatus>{}),
    Object.hashAllUnordered(filter.platforms ?? const <LinkPlatform>{}),
    Object.hashAllUnordered(filter.categoryIds ?? const <String>{}),
  );

  static bool _sameFilter(CardFilter a, CardFilter b) {
    return a.uncategorized == b.uncategorized &&
        a.query == b.query &&
        a.hasImage == b.hasImage &&
        a.hasNotes == b.hasNotes &&
        a.createdAfter == b.createdAfter &&
        a.createdBefore == b.createdBefore &&
        _sameSet(a.statuses, b.statuses) &&
        _sameSet(a.platforms, b.platforms) &&
        _sameSet(a.categoryIds, b.categoryIds);
  }

  static bool _sameSet<T>(Set<T>? a, Set<T>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return a.length == b.length && a.containsAll(b);
  }
}

final linksProvider = StreamProvider.family<List<LinkCard>, LinkQuery>((Ref ref, LinkQuery query) {
      return ref
          .watch(linkRepositoryProvider)
          .watchLinks(
            filter: query.filter,
            sort: query.sort,
            limit: query.limit,
            offset: query.offset,
          );
    });

/// Contadores por estado, para las pestañas de la lista y el Kanban.
final StreamProvider<Map<CardStatus, int>> statusCountsProvider =
    StreamProvider<Map<CardStatus, int>>(
      (Ref ref) => ref.watch(linkRepositoryProvider).watchCountsByStatus(),
    );

/// Número de enlaces sin categoría: el contador de la Bandeja.
final StreamProvider<int> inboxCountProvider = StreamProvider<int>(
  (Ref ref) => ref
      .watch(linkRepositoryProvider)
      .watchCount(const CardFilter(uncategorized: true)),
);

// --- Consultas de categorías ---

final StreamProvider<List<Category>> categoriesProvider =
    StreamProvider<List<Category>>(
      (Ref ref) => ref.watch(categoryRepositoryProvider).watchAll(),
    );

final StreamProvider<List<CategorySummary>> categorySummariesProvider =
    StreamProvider<List<CategorySummary>>(
      (Ref ref) => ref.watch(categoryRepositoryProvider).watchAllWithCounts(),
    );

final categoriesOfProvider = StreamProvider.family<List<Category>, String>(
      (Ref ref, String cardId) =>
          ref.watch(categoryRepositoryProvider).watchCategoriesOf(cardId),
    );

// --- Arranque ---

/// Crea las categorías de ejemplo la primera vez que se abre la aplicación.
///
/// Es también la primera operación que toca la base de datos en un dispositivo
/// real, así que verifica de paso que la librería nativa de SQLite se empaquetó
/// correctamente.
final FutureProvider<void> seedProvider = FutureProvider<void>((Ref ref) async {
  await seedIfNeeded(
    categories: ref.watch(categoryRepositoryProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});
