import '../../categories/domain/category.dart';
import '../domain/enums.dart';
import '../domain/link_query.dart';

enum LinkDateFilter { any, today, last7Days, last30Days }

class LinkListFilters {
  const LinkListFilters({
    this.statuses = const <CardStatus>{},
    this.platforms = const <LinkPlatform>{},
    this.categoryIds = const <String>{},
    this.date = LinkDateFilter.any,
    this.hasImage,
    this.hasNotes,
    this.uncategorized = false,
  });

  final Set<CardStatus> statuses;
  final Set<LinkPlatform> platforms;
  final Set<String> categoryIds;
  final LinkDateFilter date;
  final bool? hasImage;
  final bool? hasNotes;
  final bool uncategorized;

  static const LinkListFilters empty = LinkListFilters();

  bool get isEmpty => activeCount == 0;

  int get activeCount =>
      (statuses.isEmpty ? 0 : 1) +
      (platforms.isEmpty ? 0 : 1) +
      (categoryIds.isEmpty ? 0 : 1) +
      (date == LinkDateFilter.any ? 0 : 1) +
      (hasImage == null ? 0 : 1) +
      (hasNotes == null ? 0 : 1) +
      (uncategorized ? 1 : 0);

  CardFilter toCardFilter({String? query, DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final DateTime startOfToday = DateTime(
      current.year,
      current.month,
      current.day,
    ).toUtc();
    final DateTime? createdAfter = switch (date) {
      LinkDateFilter.any => null,
      LinkDateFilter.today => startOfToday,
      LinkDateFilter.last7Days => startOfToday.subtract(
        const Duration(days: 6),
      ),
      LinkDateFilter.last30Days => startOfToday.subtract(
        const Duration(days: 29),
      ),
    };
    return CardFilter(
      statuses: statuses.isEmpty ? null : statuses,
      platforms: platforms.isEmpty ? null : platforms,
      categoryIds: categoryIds.isEmpty ? null : categoryIds,
      createdAfter: createdAfter,
      hasImage: hasImage,
      hasNotes: hasNotes,
      uncategorized: uncategorized,
      query: query,
    );
  }

  LinkListFilters withStatuses(Set<CardStatus> value) => LinkListFilters(
    statuses: value,
    platforms: platforms,
    categoryIds: categoryIds,
    date: date,
    hasImage: hasImage,
    hasNotes: hasNotes,
    uncategorized: uncategorized,
  );
}

/// Datos ya resueltos que necesita el panel; evita que el widget toque
/// repositorios y lo deja completamente testeable.
class LinkFilterOptions {
  const LinkFilterOptions({this.categories = const <Category>[]});

  final List<Category> categories;
}
