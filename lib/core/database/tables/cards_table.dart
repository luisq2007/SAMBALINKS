import 'package:drift/drift.dart';

import '../../../features/links/domain/enums.dart';

/// Un enlace guardado.
///
/// `url` conserva lo que llegó tal cual; `canonicalUrl` es la forma normalizada
/// y es la base de la detección de duplicados (§27 del PRD), por eso lleva
/// restricción UNIQUE.
@TableIndex(name: 'idx_cards_created_at', columns: <Symbol>{#createdAt})
@TableIndex(name: 'idx_cards_updated_at', columns: <Symbol>{#updatedAt})
@TableIndex(name: 'idx_cards_status', columns: <Symbol>{#status})
@TableIndex(name: 'idx_cards_platform', columns: <Symbol>{#platform})
@TableIndex(name: 'idx_cards_domain', columns: <Symbol>{#domain})
class Cards extends Table {
  /// UUID v7: ordenable por tiempo e identidad portable entre dispositivos
  /// (§50 del PRD).
  TextColumn get id => text()();

  TextColumn get url => text()();
  TextColumn get canonicalUrl => text()();
  TextColumn get domain => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  /// URL remota de la imagen de vista previa.
  TextColumn get imageUrl => text().nullable()();

  /// Ruta **relativa** al directorio de soporte de la app. Nunca absoluta: en
  /// iOS el contenedor cambia de ruta entre instalaciones.
  TextColumn get localImage => text().nullable()();

  TextColumn get faviconUrl => text().nullable()();
  TextColumn get siteName => text().nullable()();

  TextColumn get platform => text()
      .map(const LinkPlatformConverter())
      .withDefault(const Constant('other'))();

  TextColumn get status => text()
      .map(const CardStatusConverter())
      .withDefault(const Constant('pending'))();

  TextColumn get notes => text().nullable()();

  /// Texto íntegro que envió la app de origen, con su contexto.
  TextColumn get originalSharedText => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get metadataFetchedAt => dateTime().nullable()();

  TextColumn get metadataStatus => text()
      .map(const MetadataStatusConverter())
      .withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{canonicalUrl},
  ];
}

class CardStatusConverter extends TypeConverter<CardStatus, String> {
  const CardStatusConverter();

  @override
  CardStatus fromSql(String fromDb) => CardStatus.fromValue(fromDb);

  @override
  String toSql(CardStatus value) => value.value;
}

class MetadataStatusConverter extends TypeConverter<MetadataStatus, String> {
  const MetadataStatusConverter();

  @override
  MetadataStatus fromSql(String fromDb) => MetadataStatus.fromValue(fromDb);

  @override
  String toSql(MetadataStatus value) => value.value;
}

class LinkPlatformConverter extends TypeConverter<LinkPlatform, String> {
  const LinkPlatformConverter();

  @override
  LinkPlatform fromSql(String fromDb) => LinkPlatform.fromValue(fromDb);

  @override
  String toSql(LinkPlatform value) => value.value;
}
