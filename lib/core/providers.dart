import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../features/backup/data/library_backup_service.dart';
import '../features/categories/data/drift_category_repository.dart';
import '../features/categories/domain/category.dart';
import '../features/categories/domain/category_repository.dart';
import '../features/links/data/drift_link_repository.dart';
import '../features/links/data/link_saver.dart';
import '../features/links/domain/enums.dart';
import '../features/links/domain/link_card.dart';
import '../features/links/domain/link_query.dart';
import '../features/links/domain/link_repository.dart';
import '../features/metadata/data/direct_metadata_provider.dart';
import '../features/metadata/data/html_meta_strategy.dart';
import '../features/metadata/data/local_metadata_image_store.dart';
import '../features/metadata/data/metadata_enrichment_service.dart';
import '../features/metadata/data/oembed_strategy.dart';
import '../features/metadata/data/queued_metadata_provider.dart';
import '../features/metadata/domain/metadata_image_store.dart';
import '../features/metadata/domain/metadata_provider.dart';
// Se oculta Category: Drift genera una homónima y aquí manda la del dominio.
import 'database/app_database.dart' hide Category;
import 'database/daos/settings_dao.dart';
import 'database/seed.dart';
import 'network/http_client.dart';

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
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<SettingsDao> settingsDaoProvider = Provider<SettingsDao>(
  (Ref ref) => ref.watch(databaseProvider).settingsDao,
);

final Provider<Dio> metadataDioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createMetadataDio();
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final Provider<SafeHttpClient> safeHttpClientProvider =
    Provider<SafeHttpClient>(
      (Ref ref) => SafeHttpClient(ref.watch(metadataDioProvider)),
    );

final FutureProvider<Directory> applicationSupportDirectoryProvider =
    FutureProvider<Directory>((Ref ref) => getApplicationSupportDirectory());

// --- Repositorios ---

final Provider<LinkRepository> linkRepositoryProvider =
    Provider<LinkRepository>(
      (Ref ref) => DriftLinkRepository(ref.watch(databaseProvider)),
    );

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>(
      (Ref ref) => DriftCategoryRepository(ref.watch(databaseProvider)),
    );

final Provider<MetadataProvider> metadataProvider = Provider<MetadataProvider>((
  Ref ref,
) {
  final SafeHttpClient client = ref.watch(safeHttpClientProvider);
  final DirectMetadataProvider direct = DirectMetadataProvider(
    oEmbed: OEmbedStrategy(client),
    html: HtmlMetaStrategy(client),
    httpClient: client,
  );
  return QueuedMetadataProvider(direct, maximumConcurrent: 3);
});

final Provider<LinkSaver> linkSaverProvider = Provider<LinkSaver>(
  (Ref ref) => LinkSaver(
    links: ref.watch(linkRepositoryProvider),
    categories: ref.watch(categoryRepositoryProvider),
    enrichment: ref.watch(metadataEnrichmentServiceProvider),
  ),
);

final Provider<MetadataImageStore> metadataImageStoreProvider =
    Provider<MetadataImageStore>(
      (Ref ref) => LocalMetadataImageStore(ref.watch(safeHttpClientProvider)),
    );

final Provider<MetadataEnrichmentService> metadataEnrichmentServiceProvider =
    Provider<MetadataEnrichmentService>(
      (Ref ref) => MetadataEnrichmentService(
        links: ref.watch(linkRepositoryProvider),
        metadata: ref.watch(metadataProvider),
        images: ref.watch(metadataImageStoreProvider),
      ),
    );

final Provider<LibraryBackupService> libraryBackupServiceProvider =
    Provider<LibraryBackupService>(
      (Ref ref) => LibraryBackupService(ref.watch(databaseProvider)),
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

final linksProvider = StreamProvider.autoDispose
    .family<List<LinkCard>, LinkQuery>((Ref ref, LinkQuery query) {
      return ref
          .watch(linkRepositoryProvider)
          .watchLinks(
            filter: query.filter,
            sort: query.sort,
            limit: query.limit,
            offset: query.offset,
          );
    });

final linkCountProvider = StreamProvider.autoDispose.family<int, LinkQuery>(
  (Ref ref, LinkQuery query) =>
      ref.watch(linkRepositoryProvider).watchCount(query.filter),
);

/// Contadores por estado, para las pestañas de la lista y el Kanban.
final StreamProvider<Map<CardStatus, int>> statusCountsProvider =
    StreamProvider<Map<CardStatus, int>>(
      (Ref ref) => ref.watch(linkRepositoryProvider).watchCountsByStatus(),
    );

/// Contadores por estado acotados a un ámbito (Bandeja, categoría, búsqueda).
///
/// El `statusCountsProvider` global se mantiene para las insignias de la
/// navegación, donde el total sí es lo que se quiere.
final scopedStatusCountsProvider = StreamProvider.autoDispose
    .family<Map<CardStatus, int>, LinkQuery>(
      (Ref ref, LinkQuery query) =>
          ref.watch(linkRepositoryProvider).watchCountsByStatus(query.filter),
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

// --- Preferencias de presentación ---

final AsyncNotifierProvider<CardSortController, CardSort>
cardSortPreferenceProvider =
    AsyncNotifierProvider<CardSortController, CardSort>(CardSortController.new);

class CardSortController extends AsyncNotifier<CardSort> {
  @override
  Future<CardSort> build() async {
    final String? stored = await ref
        .watch(settingsDaoProvider)
        .read<String>(SettingsKeys.defaultSort);
    return CardSort.values.firstWhere(
      (CardSort value) => value.name == stored,
      orElse: () => CardSort.newest,
    );
  }

  Future<void> setSort(CardSort sort) async {
    state = AsyncData<CardSort>(sort);
    await ref
        .read(settingsDaoProvider)
        .write(SettingsKeys.defaultSort, sort.name);
  }
}

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

/// Elimina al arrancar archivos que ya no tienen tarjeta, sin bloquear más de
/// un cuarto de segundo aunque la biblioteca sea grande.
final FutureProvider<void> orphanImageCleanupProvider = FutureProvider<void>((
  Ref ref,
) async {
  await ref.watch(metadataEnrichmentServiceProvider).cleanupOrphanedImages();
});
