import '../../categories/domain/category.dart';
import '../../links/domain/enums.dart';
import '../../links/domain/link_card.dart';

/// Versión del formato portable. Sube sólo si el cambio rompe a un lector
/// antiguo; añadir campos no la sube, porque el importador ignora lo que no
/// conoce.
const int kLibrarySchemaVersion = 1;

/// Relación entre un enlace y una categoría, tal como viaja en el JSON.
class SnapshotRelation {
  const SnapshotRelation({
    required this.cardId,
    required this.categoryId,
    required this.createdAt,
  });

  final String cardId;
  final String categoryId;
  final DateTime createdAt;
}

/// Toda la biblioteca en memoria, lista para serializar (§29 del PRD).
class LibrarySnapshot {
  const LibrarySnapshot({
    required this.exportedAt,
    required this.cards,
    required this.categories,
    required this.relations,
    required this.settings,
    this.schemaVersion = kLibrarySchemaVersion,
    this.appVersion,
  });

  final int schemaVersion;
  final String? appVersion;
  final DateTime exportedAt;
  final List<LinkCard> cards;
  final List<Category> categories;
  final List<SnapshotRelation> relations;
  final Map<String, Object?> settings;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'application': 'SambaLinks',
      if (appVersion != null) 'appVersion': appVersion,
      'exportedAt': _iso(exportedAt),
      // Permite detectar un archivo truncado antes de empezar a importar.
      'counts': <String, int>{
        'cards': cards.length,
        'categories': categories.length,
        'cardCategories': relations.length,
      },
      'settings': settings,
      'categories': <Map<String, Object?>>[
        for (final Category c in categories)
          <String, Object?>{
            'id': c.id,
            'name': c.name,
            'color': c.color,
            'icon': c.icon,
            'sortOrder': c.sortOrder,
            'createdAt': _iso(c.createdAt),
            'updatedAt': _iso(c.updatedAt),
          },
      ],
      'cards': <Map<String, Object?>>[
        for (final LinkCard card in cards)
          <String, Object?>{
            'id': card.id,
            'url': card.url,
            'canonicalUrl': card.canonicalUrl,
            'domain': card.domain,
            'title': card.title,
            'description': card.description,
            'imageUrl': card.imageUrl,
            'faviconUrl': card.faviconUrl,
            'siteName': card.siteName,
            'platform': card.platform.value,
            'status': card.status.value,
            'notes': card.notes,
            'originalSharedText': card.originalSharedText,
            'createdAt': _iso(card.createdAt),
            'updatedAt': _iso(card.updatedAt),
            'metadataFetchedAt': card.metadataFetchedAt == null
                ? null
                : _iso(card.metadataFetchedAt!),
            'metadataStatus': card.metadataStatus.value,
            // `localImage` NO se exporta: es una ruta de este dispositivo y no
            // significa nada fuera de él.
          },
      ],
      'cardCategories': <Map<String, Object?>>[
        for (final SnapshotRelation r in relations)
          <String, Object?>{
            'cardId': r.cardId,
            'categoryId': r.categoryId,
            'createdAt': _iso(r.createdAt),
          },
      ],
    };
  }

  static LibrarySnapshot fromJson(Map<String, Object?> json) {
    final int version = _int(json['schemaVersion']) ?? 0;
    if (version > kLibrarySchemaVersion) {
      throw UnsupportedSchemaVersion(version);
    }
    if (json['cards'] is! List || json['categories'] is! List) {
      throw const MalformedBackup();
    }

    return LibrarySnapshot(
      schemaVersion: version,
      appVersion: json['appVersion'] as String?,
      exportedAt: _date(json['exportedAt']) ?? DateTime.now().toUtc(),
      settings: (json['settings'] as Map<String, Object?>?) ??
          const <String, Object?>{},
      categories: <Category>[
        for (final Object? raw in json['categories']! as List<Object?>)
          if (raw is Map<String, Object?>) _category(raw),
      ],
      cards: <LinkCard>[
        for (final Object? raw in json['cards']! as List<Object?>)
          if (raw is Map<String, Object?>) _card(raw),
      ],
      relations: <SnapshotRelation>[
        for (final Object? raw
            in (json['cardCategories'] as List<Object?>?) ?? const <Object?>[])
          if (raw is Map<String, Object?> &&
              raw['cardId'] is String &&
              raw['categoryId'] is String)
            SnapshotRelation(
              cardId: raw['cardId']! as String,
              categoryId: raw['categoryId']! as String,
              createdAt: _date(raw['createdAt']) ?? DateTime.now().toUtc(),
            ),
      ],
    );
  }

  static Category _category(Map<String, Object?> raw) {
    final DateTime now = DateTime.now().toUtc();
    return Category(
      id: raw['id']! as String,
      name: raw['name']! as String,
      color: raw['color'] as String?,
      icon: raw['icon'] as String?,
      sortOrder: _int(raw['sortOrder']) ?? 0,
      createdAt: _date(raw['createdAt']) ?? now,
      updatedAt: _date(raw['updatedAt']) ?? now,
    );
  }

  static LinkCard _card(Map<String, Object?> raw) {
    final DateTime now = DateTime.now().toUtc();
    final String url = (raw['url'] ?? raw['canonicalUrl'])! as String;
    return LinkCard(
      id: raw['id']! as String,
      url: url,
      canonicalUrl: (raw['canonicalUrl'] as String?) ?? url,
      domain: (raw['domain'] as String?) ?? '',
      title: raw['title'] as String?,
      description: raw['description'] as String?,
      imageUrl: raw['imageUrl'] as String?,
      faviconUrl: raw['faviconUrl'] as String?,
      siteName: raw['siteName'] as String?,
      platform: LinkPlatform.fromValue((raw['platform'] as String?) ?? 'other'),
      status: CardStatus.fromValue((raw['status'] as String?) ?? 'pending'),
      notes: raw['notes'] as String?,
      originalSharedText: raw['originalSharedText'] as String?,
      createdAt: _date(raw['createdAt']) ?? now,
      updatedAt: _date(raw['updatedAt']) ?? now,
      metadataFetchedAt: _date(raw['metadataFetchedAt']),
      metadataStatus: MetadataStatus.fromValue(
        (raw['metadataStatus'] as String?) ?? 'pending',
      ),
    );
  }

  /// ISO-8601 **en UTC**, siempre.
  ///
  /// Drift devuelve las fechas en hora local, así que sin esta conversión el
  /// archivo saldría con la zona horaria de quien exporta y dos bibliotecas
  /// idénticas producirían JSON distintos.
  static String _iso(DateTime value) => value.toUtc().toIso8601String();

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

  static int? _int(Object? raw) => raw is int
      ? raw
      : (raw is num ? raw.toInt() : (raw is String ? int.tryParse(raw) : null));
}

/// El archivo viene de una versión futura de SambaLinks.
class UnsupportedSchemaVersion implements Exception {
  const UnsupportedSchemaVersion(this.version);

  final int version;
}

/// El archivo no tiene la forma de una biblioteca de SambaLinks.
class MalformedBackup implements Exception {
  const MalformedBackup();
}
