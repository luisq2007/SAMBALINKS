import 'package:drift/drift.dart';

import '../../../features/links/domain/enums.dart';
import '../../../features/links/domain/link_query.dart';
import '../app_database.dart';
import '../tables/cards_table.dart';
import '../tables/categories_table.dart';

part 'cards_dao.g.dart';

@DriftAccessor(tables: <Type>[Cards, Categories, CardCategories])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Future<Card?> findById(String id) {
    return (select(cards)..where(($CardsTable t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Busca por URL canónica. Es la consulta de detección de duplicados (§27).
  Future<Card?> findByCanonicalUrl(String canonicalUrl) {
    return (select(
      cards,
    )..where(($CardsTable t) => t.canonicalUrl.equals(canonicalUrl))).getSingleOrNull();
  }

  Future<void> upsert(CardsCompanion card) =>
      into(cards).insertOnConflictUpdate(card);

  Future<int> deleteById(String id) =>
      (delete(cards)..where(($CardsTable t) => t.id.equals(id))).go();

  /// Lista paginada y reactiva. La UI se actualiza sola ante cualquier cambio.
  Stream<List<Card>> watchCards({
    CardFilter filter = const CardFilter(),
    CardSort sort = CardSort.newest,
    int? limit,
    int offset = 0,
  }) {
    final SimpleSelectStatement<$CardsTable, Card> statement = select(cards)
      ..where(($CardsTable t) => _buildPredicate(t, filter))
      ..orderBy(_orderingFor(sort));

    if (limit != null) {
      statement.limit(limit, offset: offset);
    }
    return statement.watch();
  }

  Future<List<Card>> getCards({
    CardFilter filter = const CardFilter(),
    CardSort sort = CardSort.newest,
    int? limit,
    int offset = 0,
  }) {
    return watchCards(
      filter: filter,
      sort: sort,
      limit: limit,
      offset: offset,
    ).first;
  }

  Stream<int> watchCount([CardFilter filter = const CardFilter()]) {
    final Expression<int> total = cards.id.count();
    final JoinedSelectStatement<HasResultSet, dynamic> statement =
        selectOnly(cards)
          ..addColumns(<Expression<Object>>[total])
          ..where(_buildPredicate(cards, filter));

    return statement.watchSingle().map(
      (TypedResult row) => row.read(total) ?? 0,
    );
  }

  /// Contadores por estado en una sola consulta, para los encabezados del
  /// Kanban y las pestañas de la lista.
  Stream<Map<CardStatus, int>> watchCountsByStatus() {
    final Expression<int> total = cards.id.count();
    final JoinedSelectStatement<HasResultSet, dynamic> statement =
        selectOnly(cards)
          ..addColumns(<Expression<Object>>[cards.status, total])
          ..groupBy(<Expression<Object>>[cards.status]);

    return statement.watch().map((List<TypedResult> rows) {
      final Map<CardStatus, int> counts = <CardStatus, int>{
        for (final CardStatus s in CardStatus.values) s: 0,
      };
      for (final TypedResult row in rows) {
        final CardStatus? status = row.readWithConverter(cards.status);
        if (status != null) {
          counts[status] = row.read(total) ?? 0;
        }
      }
      return counts;
    });
  }

  Expression<bool> _buildPredicate(covariant $CardsTable t, CardFilter f) {
    Expression<bool> predicate = const Constant<bool>(true);

    if (f.statuses != null && f.statuses!.isNotEmpty) {
      predicate = predicate &
          t.status.isIn(f.statuses!.map((CardStatus s) => s.value).toList());
    }
    if (f.platforms != null && f.platforms!.isNotEmpty) {
      predicate = predicate &
          t.platform.isIn(f.platforms!.map((LinkPlatform p) => p.value).toList());
    }
    if (f.createdAfter != null) {
      predicate = predicate & t.createdAt.isBiggerOrEqualValue(f.createdAfter!);
    }
    if (f.createdBefore != null) {
      predicate = predicate & t.createdAt.isSmallerOrEqualValue(f.createdBefore!);
    }
    if (f.hasImage != null) {
      final Expression<bool> withImage =
          t.imageUrl.isNotNull() | t.localImage.isNotNull();
      predicate = predicate & (f.hasImage! ? withImage : withImage.not());
    }
    if (f.hasNotes != null) {
      final Expression<bool> withNotes =
          t.notes.isNotNull() & t.notes.trim().equals('').not();
      predicate = predicate & (f.hasNotes! ? withNotes : withNotes.not());
    }

    // La Bandeja no es una categoría: es la ausencia de relaciones.
    if (f.uncategorized) {
      predicate = predicate &
          notExistsQuery(
            select(cardCategories)
              ..where(($CardCategoriesTable cc) => cc.cardId.equalsExp(t.id)),
          );
    }

    if (f.categoryIds != null && f.categoryIds!.isNotEmpty) {
      predicate = predicate &
          existsQuery(
            select(cardCategories)
              ..where(
                ($CardCategoriesTable cc) =>
                    cc.cardId.equalsExp(t.id) &
                    cc.categoryId.isIn(f.categoryIds!.toList()),
              ),
          );
    }

    final String? q = f.query?.trim();
    if (q != null && q.isNotEmpty) {
      final String pattern = '%${q.toLowerCase()}%';
      Expression<bool> matches = t.title.lower().like(pattern) |
          t.description.lower().like(pattern) |
          t.domain.lower().like(pattern) |
          t.url.lower().like(pattern) |
          t.notes.lower().like(pattern) |
          t.platform.lower().like(pattern);

      // La búsqueda también alcanza el nombre de las categorías (§20).
      matches = matches |
          existsQuery(
            select(cardCategories).join(<Join<HasResultSet, dynamic>>[
              innerJoin(
                categories,
                categories.id.equalsExp(cardCategories.categoryId),
              ),
            ])..where(
              cardCategories.cardId.equalsExp(t.id) &
                  categories.name.lower().like(pattern),
            ),
          );

      predicate = predicate & matches;
    }

    return predicate;
  }

  List<OrderClauseGenerator<$CardsTable>> _orderingFor(CardSort sort) {
    return switch (sort) {
      // El desempate por id es estable porque el UUID v7 es monótono.
      CardSort.newest => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.desc(t.createdAt),
        ($CardsTable t) => OrderingTerm.desc(t.id),
      ],
      CardSort.oldest => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.asc(t.createdAt),
        ($CardsTable t) => OrderingTerm.asc(t.id),
      ],
      CardSort.recentlyUpdated => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.desc(t.updatedAt),
      ],
      CardSort.titleAsc => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.asc(t.title),
      ],
      CardSort.titleDesc => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.desc(t.title),
      ],
      CardSort.platform => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.asc(t.platform),
        ($CardsTable t) => OrderingTerm.desc(t.createdAt),
      ],
      CardSort.status => <OrderClauseGenerator<$CardsTable>>[
        ($CardsTable t) => OrderingTerm.asc(t.status),
        ($CardsTable t) => OrderingTerm.desc(t.createdAt),
      ],
    };
  }
}
