import 'enums.dart';

/// Criterios de filtrado combinables (§19 del PRD).
///
/// Todos los campos son opcionales y se combinan con AND. `null` significa
/// "no filtrar por esto", que no es lo mismo que una lista vacía.
class CardFilter {
  const CardFilter({
    this.statuses,
    this.platforms,
    this.categoryIds,
    this.createdAfter,
    this.createdBefore,
    this.hasImage,
    this.hasNotes,
    this.uncategorized = false,
    this.query,
  });

  final Set<CardStatus>? statuses;
  final Set<LinkPlatform>? platforms;
  final Set<String>? categoryIds;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final bool? hasImage;
  final bool? hasNotes;

  /// Sólo enlaces sin ninguna categoría: la Bandeja (§16).
  final bool uncategorized;

  /// Búsqueda global (§20).
  final String? query;

  bool get isEmpty =>
      statuses == null &&
      platforms == null &&
      categoryIds == null &&
      createdAfter == null &&
      createdBefore == null &&
      hasImage == null &&
      hasNotes == null &&
      !uncategorized &&
      (query == null || query!.trim().isEmpty);
}

/// Criterios de ordenación (§18 del PRD).
enum CardSort { newest, oldest, recentlyUpdated, titleAsc, titleDesc, platform, status }
