// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalUrlMeta = const VerificationMeta(
    'canonicalUrl',
  );
  @override
  late final GeneratedColumn<String> canonicalUrl = GeneratedColumn<String>(
    'canonical_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localImageMeta = const VerificationMeta(
    'localImage',
  );
  @override
  late final GeneratedColumn<String> localImage = GeneratedColumn<String>(
    'local_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faviconUrlMeta = const VerificationMeta(
    'faviconUrl',
  );
  @override
  late final GeneratedColumn<String> faviconUrl = GeneratedColumn<String>(
    'favicon_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LinkPlatform, String> platform =
      GeneratedColumn<String>(
        'platform',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('other'),
      ).withConverter<LinkPlatform>($CardsTable.$converterplatform);
  @override
  late final GeneratedColumnWithTypeConverter<CardStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<CardStatus>($CardsTable.$converterstatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSharedTextMeta =
      const VerificationMeta('originalSharedText');
  @override
  late final GeneratedColumn<String> originalSharedText =
      GeneratedColumn<String>(
        'original_shared_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataFetchedAtMeta = const VerificationMeta(
    'metadataFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> metadataFetchedAt =
      GeneratedColumn<DateTime>(
        'metadata_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MetadataStatus, String>
  metadataStatus = GeneratedColumn<String>(
    'metadata_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  ).withConverter<MetadataStatus>($CardsTable.$convertermetadataStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    canonicalUrl,
    domain,
    title,
    description,
    imageUrl,
    localImage,
    faviconUrl,
    siteName,
    platform,
    status,
    notes,
    originalSharedText,
    createdAt,
    updatedAt,
    metadataFetchedAt,
    metadataStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('canonical_url')) {
      context.handle(
        _canonicalUrlMeta,
        canonicalUrl.isAcceptableOrUnknown(
          data['canonical_url']!,
          _canonicalUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalUrlMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('local_image')) {
      context.handle(
        _localImageMeta,
        localImage.isAcceptableOrUnknown(data['local_image']!, _localImageMeta),
      );
    }
    if (data.containsKey('favicon_url')) {
      context.handle(
        _faviconUrlMeta,
        faviconUrl.isAcceptableOrUnknown(data['favicon_url']!, _faviconUrlMeta),
      );
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('original_shared_text')) {
      context.handle(
        _originalSharedTextMeta,
        originalSharedText.isAcceptableOrUnknown(
          data['original_shared_text']!,
          _originalSharedTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('metadata_fetched_at')) {
      context.handle(
        _metadataFetchedAtMeta,
        metadataFetchedAt.isAcceptableOrUnknown(
          data['metadata_fetched_at']!,
          _metadataFetchedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {canonicalUrl},
  ];
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      canonicalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_url'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      localImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image'],
      ),
      faviconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon_url'],
      ),
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      ),
      platform: $CardsTable.$converterplatform.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}platform'],
        )!,
      ),
      status: $CardsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      originalSharedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_shared_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      metadataFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}metadata_fetched_at'],
      ),
      metadataStatus: $CardsTable.$convertermetadataStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metadata_status'],
        )!,
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }

  static TypeConverter<LinkPlatform, String> $converterplatform =
      const LinkPlatformConverter();
  static TypeConverter<CardStatus, String> $converterstatus =
      const CardStatusConverter();
  static TypeConverter<MetadataStatus, String> $convertermetadataStatus =
      const MetadataStatusConverter();
}

class Card extends DataClass implements Insertable<Card> {
  /// UUID v7: ordenable por tiempo e identidad portable entre dispositivos
  /// (§50 del PRD).
  final String id;
  final String url;
  final String canonicalUrl;
  final String domain;
  final String? title;
  final String? description;

  /// URL remota de la imagen de vista previa.
  final String? imageUrl;

  /// Ruta **relativa** al directorio de soporte de la app. Nunca absoluta: en
  /// iOS el contenedor cambia de ruta entre instalaciones.
  final String? localImage;
  final String? faviconUrl;
  final String? siteName;
  final LinkPlatform platform;
  final CardStatus status;
  final String? notes;

  /// Texto íntegro que envió la app de origen, con su contexto.
  final String? originalSharedText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? metadataFetchedAt;
  final MetadataStatus metadataStatus;
  const Card({
    required this.id,
    required this.url,
    required this.canonicalUrl,
    required this.domain,
    this.title,
    this.description,
    this.imageUrl,
    this.localImage,
    this.faviconUrl,
    this.siteName,
    required this.platform,
    required this.status,
    this.notes,
    this.originalSharedText,
    required this.createdAt,
    required this.updatedAt,
    this.metadataFetchedAt,
    required this.metadataStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['canonical_url'] = Variable<String>(canonicalUrl);
    map['domain'] = Variable<String>(domain);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || localImage != null) {
      map['local_image'] = Variable<String>(localImage);
    }
    if (!nullToAbsent || faviconUrl != null) {
      map['favicon_url'] = Variable<String>(faviconUrl);
    }
    if (!nullToAbsent || siteName != null) {
      map['site_name'] = Variable<String>(siteName);
    }
    {
      map['platform'] = Variable<String>(
        $CardsTable.$converterplatform.toSql(platform),
      );
    }
    {
      map['status'] = Variable<String>(
        $CardsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || originalSharedText != null) {
      map['original_shared_text'] = Variable<String>(originalSharedText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || metadataFetchedAt != null) {
      map['metadata_fetched_at'] = Variable<DateTime>(metadataFetchedAt);
    }
    {
      map['metadata_status'] = Variable<String>(
        $CardsTable.$convertermetadataStatus.toSql(metadataStatus),
      );
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      url: Value(url),
      canonicalUrl: Value(canonicalUrl),
      domain: Value(domain),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      localImage: localImage == null && nullToAbsent
          ? const Value.absent()
          : Value(localImage),
      faviconUrl: faviconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(faviconUrl),
      siteName: siteName == null && nullToAbsent
          ? const Value.absent()
          : Value(siteName),
      platform: Value(platform),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      originalSharedText: originalSharedText == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSharedText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadataFetchedAt: metadataFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataFetchedAt),
      metadataStatus: Value(metadataStatus),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      canonicalUrl: serializer.fromJson<String>(json['canonicalUrl']),
      domain: serializer.fromJson<String>(json['domain']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      localImage: serializer.fromJson<String?>(json['localImage']),
      faviconUrl: serializer.fromJson<String?>(json['faviconUrl']),
      siteName: serializer.fromJson<String?>(json['siteName']),
      platform: serializer.fromJson<LinkPlatform>(json['platform']),
      status: serializer.fromJson<CardStatus>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      originalSharedText: serializer.fromJson<String?>(
        json['originalSharedText'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      metadataFetchedAt: serializer.fromJson<DateTime?>(
        json['metadataFetchedAt'],
      ),
      metadataStatus: serializer.fromJson<MetadataStatus>(
        json['metadataStatus'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'canonicalUrl': serializer.toJson<String>(canonicalUrl),
      'domain': serializer.toJson<String>(domain),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'localImage': serializer.toJson<String?>(localImage),
      'faviconUrl': serializer.toJson<String?>(faviconUrl),
      'siteName': serializer.toJson<String?>(siteName),
      'platform': serializer.toJson<LinkPlatform>(platform),
      'status': serializer.toJson<CardStatus>(status),
      'notes': serializer.toJson<String?>(notes),
      'originalSharedText': serializer.toJson<String?>(originalSharedText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'metadataFetchedAt': serializer.toJson<DateTime?>(metadataFetchedAt),
      'metadataStatus': serializer.toJson<MetadataStatus>(metadataStatus),
    };
  }

  Card copyWith({
    String? id,
    String? url,
    String? canonicalUrl,
    String? domain,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> localImage = const Value.absent(),
    Value<String?> faviconUrl = const Value.absent(),
    Value<String?> siteName = const Value.absent(),
    LinkPlatform? platform,
    CardStatus? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> originalSharedText = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> metadataFetchedAt = const Value.absent(),
    MetadataStatus? metadataStatus,
  }) => Card(
    id: id ?? this.id,
    url: url ?? this.url,
    canonicalUrl: canonicalUrl ?? this.canonicalUrl,
    domain: domain ?? this.domain,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    localImage: localImage.present ? localImage.value : this.localImage,
    faviconUrl: faviconUrl.present ? faviconUrl.value : this.faviconUrl,
    siteName: siteName.present ? siteName.value : this.siteName,
    platform: platform ?? this.platform,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    originalSharedText: originalSharedText.present
        ? originalSharedText.value
        : this.originalSharedText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    metadataFetchedAt: metadataFetchedAt.present
        ? metadataFetchedAt.value
        : this.metadataFetchedAt,
    metadataStatus: metadataStatus ?? this.metadataStatus,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      canonicalUrl: data.canonicalUrl.present
          ? data.canonicalUrl.value
          : this.canonicalUrl,
      domain: data.domain.present ? data.domain.value : this.domain,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      localImage: data.localImage.present
          ? data.localImage.value
          : this.localImage,
      faviconUrl: data.faviconUrl.present
          ? data.faviconUrl.value
          : this.faviconUrl,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      platform: data.platform.present ? data.platform.value : this.platform,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      originalSharedText: data.originalSharedText.present
          ? data.originalSharedText.value
          : this.originalSharedText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadataFetchedAt: data.metadataFetchedAt.present
          ? data.metadataFetchedAt.value
          : this.metadataFetchedAt,
      metadataStatus: data.metadataStatus.present
          ? data.metadataStatus.value
          : this.metadataStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImage: $localImage, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('siteName: $siteName, ')
          ..write('platform: $platform, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('originalSharedText: $originalSharedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadataFetchedAt: $metadataFetchedAt, ')
          ..write('metadataStatus: $metadataStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    canonicalUrl,
    domain,
    title,
    description,
    imageUrl,
    localImage,
    faviconUrl,
    siteName,
    platform,
    status,
    notes,
    originalSharedText,
    createdAt,
    updatedAt,
    metadataFetchedAt,
    metadataStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.url == this.url &&
          other.canonicalUrl == this.canonicalUrl &&
          other.domain == this.domain &&
          other.title == this.title &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.localImage == this.localImage &&
          other.faviconUrl == this.faviconUrl &&
          other.siteName == this.siteName &&
          other.platform == this.platform &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.originalSharedText == this.originalSharedText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadataFetchedAt == this.metadataFetchedAt &&
          other.metadataStatus == this.metadataStatus);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> canonicalUrl;
  final Value<String> domain;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String?> localImage;
  final Value<String?> faviconUrl;
  final Value<String?> siteName;
  final Value<LinkPlatform> platform;
  final Value<CardStatus> status;
  final Value<String?> notes;
  final Value<String?> originalSharedText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> metadataFetchedAt;
  final Value<MetadataStatus> metadataStatus;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.canonicalUrl = const Value.absent(),
    this.domain = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.localImage = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.siteName = const Value.absent(),
    this.platform = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.originalSharedText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadataFetchedAt = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String url,
    required String canonicalUrl,
    required String domain,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.localImage = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.siteName = const Value.absent(),
    this.platform = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.originalSharedText = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.metadataFetchedAt = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       canonicalUrl = Value(canonicalUrl),
       domain = Value(domain),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? canonicalUrl,
    Expression<String>? domain,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? localImage,
    Expression<String>? faviconUrl,
    Expression<String>? siteName,
    Expression<String>? platform,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? originalSharedText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? metadataFetchedAt,
    Expression<String>? metadataStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (canonicalUrl != null) 'canonical_url': canonicalUrl,
      if (domain != null) 'domain': domain,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (localImage != null) 'local_image': localImage,
      if (faviconUrl != null) 'favicon_url': faviconUrl,
      if (siteName != null) 'site_name': siteName,
      if (platform != null) 'platform': platform,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (originalSharedText != null)
        'original_shared_text': originalSharedText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadataFetchedAt != null) 'metadata_fetched_at': metadataFetchedAt,
      if (metadataStatus != null) 'metadata_status': metadataStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? canonicalUrl,
    Value<String>? domain,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<String?>? localImage,
    Value<String?>? faviconUrl,
    Value<String?>? siteName,
    Value<LinkPlatform>? platform,
    Value<CardStatus>? status,
    Value<String?>? notes,
    Value<String?>? originalSharedText,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? metadataFetchedAt,
    Value<MetadataStatus>? metadataStatus,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      domain: domain ?? this.domain,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      localImage: localImage ?? this.localImage,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      siteName: siteName ?? this.siteName,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      originalSharedText: originalSharedText ?? this.originalSharedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadataFetchedAt: metadataFetchedAt ?? this.metadataFetchedAt,
      metadataStatus: metadataStatus ?? this.metadataStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (canonicalUrl.present) {
      map['canonical_url'] = Variable<String>(canonicalUrl.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (localImage.present) {
      map['local_image'] = Variable<String>(localImage.value);
    }
    if (faviconUrl.present) {
      map['favicon_url'] = Variable<String>(faviconUrl.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(
        $CardsTable.$converterplatform.toSql(platform.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CardsTable.$converterstatus.toSql(status.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (originalSharedText.present) {
      map['original_shared_text'] = Variable<String>(originalSharedText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (metadataFetchedAt.present) {
      map['metadata_fetched_at'] = Variable<DateTime>(metadataFetchedAt.value);
    }
    if (metadataStatus.present) {
      map['metadata_status'] = Variable<String>(
        $CardsTable.$convertermetadataStatus.toSql(metadataStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImage: $localImage, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('siteName: $siteName, ')
          ..write('platform: $platform, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('originalSharedText: $originalSharedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadataFetchedAt: $metadataFetchedAt, ')
          ..write('metadataStatus: $metadataStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    icon,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;

  /// Hex de la paleta, p. ej. "#B9ECFA".
  final String? color;

  /// Clave de un catálogo propio de iconos ("lightbulb", "code"), **no** un
  /// codePoint de IconData: los codePoints rompen con el tree-shaking de
  /// iconos y no son portables entre versiones de Flutter, lo que arruinaría
  /// el JSON de exportación.
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Value<String?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, icon, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? color,
    Value<String?>? icon,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardCategoriesTable extends CardCategories
    with TableInfo<$CardCategoriesTable, CardCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, categoryId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, categoryId};
  @override
  CardCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardCategory(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardCategoriesTable createAlias(String alias) {
    return $CardCategoriesTable(attachedDatabase, alias);
  }
}

class CardCategory extends DataClass implements Insertable<CardCategory> {
  final String cardId;
  final String categoryId;
  final DateTime createdAt;
  const CardCategory({
    required this.cardId,
    required this.categoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['category_id'] = Variable<String>(categoryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CardCategoriesCompanion(
      cardId: Value(cardId),
      categoryId: Value(categoryId),
      createdAt: Value(createdAt),
    );
  }

  factory CardCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardCategory(
      cardId: serializer.fromJson<String>(json['cardId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'categoryId': serializer.toJson<String>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardCategory copyWith({
    String? cardId,
    String? categoryId,
    DateTime? createdAt,
  }) => CardCategory(
    cardId: cardId ?? this.cardId,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  CardCategory copyWithCompanion(CardCategoriesCompanion data) {
    return CardCategory(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardCategory(')
          ..write('cardId: $cardId, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, categoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardCategory &&
          other.cardId == this.cardId &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt);
}

class CardCategoriesCompanion extends UpdateCompanion<CardCategory> {
  final Value<String> cardId;
  final Value<String> categoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardCategoriesCompanion({
    this.cardId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardCategoriesCompanion.insert({
    required String cardId,
    required String categoryId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt);
  static Insertable<CardCategory> custom({
    Expression<String>? cardId,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardCategoriesCompanion copyWith({
    Value<String>? cardId,
    Value<String>? categoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardCategoriesCompanion(
      cardId: cardId ?? this.cardId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardCategoriesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CardCategoriesTable cardCategories = $CardCategoriesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index idxCardsCreatedAt = Index(
    'idx_cards_created_at',
    'CREATE INDEX idx_cards_created_at ON cards (created_at)',
  );
  late final Index idxCardsUpdatedAt = Index(
    'idx_cards_updated_at',
    'CREATE INDEX idx_cards_updated_at ON cards (updated_at)',
  );
  late final Index idxCardsStatus = Index(
    'idx_cards_status',
    'CREATE INDEX idx_cards_status ON cards (status)',
  );
  late final Index idxCardsPlatform = Index(
    'idx_cards_platform',
    'CREATE INDEX idx_cards_platform ON cards (platform)',
  );
  late final Index idxCardsDomain = Index(
    'idx_cards_domain',
    'CREATE INDEX idx_cards_domain ON cards (domain)',
  );
  late final Index idxCcCard = Index(
    'idx_cc_card',
    'CREATE INDEX idx_cc_card ON card_categories (card_id)',
  );
  late final Index idxCcCategory = Index(
    'idx_cc_category',
    'CREATE INDEX idx_cc_category ON card_categories (category_id)',
  );
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final CardCategoriesDao cardCategoriesDao = CardCategoriesDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cards,
    categories,
    cardCategories,
    appSettings,
    idxCardsCreatedAt,
    idxCardsUpdatedAt,
    idxCardsStatus,
    idxCardsPlatform,
    idxCardsDomain,
    idxCcCard,
    idxCcCategory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_categories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      required String url,
      required String canonicalUrl,
      required String domain,
      Value<String?> title,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String?> localImage,
      Value<String?> faviconUrl,
      Value<String?> siteName,
      Value<LinkPlatform> platform,
      Value<CardStatus> status,
      Value<String?> notes,
      Value<String?> originalSharedText,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> metadataFetchedAt,
      Value<MetadataStatus> metadataStatus,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> canonicalUrl,
      Value<String> domain,
      Value<String?> title,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String?> localImage,
      Value<String?> faviconUrl,
      Value<String?> siteName,
      Value<LinkPlatform> platform,
      Value<CardStatus> status,
      Value<String?> notes,
      Value<String?> originalSharedText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> metadataFetchedAt,
      Value<MetadataStatus> metadataStatus,
      Value<int> rowid,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardCategoriesTable, List<CardCategory>>
  _cardCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardCategories,
    aliasName: 'cards__id__card_categories__card_id',
  );

  $$CardCategoriesTableProcessedTableManager get cardCategoriesRefs {
    final manager = $$CardCategoriesTableTableManager(
      $_db,
      $_db.cardCategories,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardCategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalUrl => $composableBuilder(
    column: $table.canonicalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImage => $composableBuilder(
    column: $table.localImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LinkPlatform, LinkPlatform, String>
  get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CardStatus, CardStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSharedText => $composableBuilder(
    column: $table.originalSharedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get metadataFetchedAt => $composableBuilder(
    column: $table.metadataFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MetadataStatus, MetadataStatus, String>
  get metadataStatus => $composableBuilder(
    column: $table.metadataStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> cardCategoriesRefs(
    Expression<bool> Function($$CardCategoriesTableFilterComposer f) f,
  ) {
    final $$CardCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardCategories,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.cardCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalUrl => $composableBuilder(
    column: $table.canonicalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImage => $composableBuilder(
    column: $table.localImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSharedText => $composableBuilder(
    column: $table.originalSharedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get metadataFetchedAt => $composableBuilder(
    column: $table.metadataFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataStatus => $composableBuilder(
    column: $table.metadataStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get canonicalUrl => $composableBuilder(
    column: $table.canonicalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get localImage => $composableBuilder(
    column: $table.localImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LinkPlatform, String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get originalSharedText => $composableBuilder(
    column: $table.originalSharedText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get metadataFetchedAt => $composableBuilder(
    column: $table.metadataFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MetadataStatus, String> get metadataStatus =>
      $composableBuilder(
        column: $table.metadataStatus,
        builder: (column) => column,
      );

  Expression<T> cardCategoriesRefs<T extends Object>(
    Expression<T> Function($$CardCategoriesTableAnnotationComposer a) f,
  ) {
    final $$CardCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardCategories,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({bool cardCategoriesRefs})
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> canonicalUrl = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> localImage = const Value.absent(),
                Value<String?> faviconUrl = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<LinkPlatform> platform = const Value.absent(),
                Value<CardStatus> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> originalSharedText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> metadataFetchedAt = const Value.absent(),
                Value<MetadataStatus> metadataStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                url: url,
                canonicalUrl: canonicalUrl,
                domain: domain,
                title: title,
                description: description,
                imageUrl: imageUrl,
                localImage: localImage,
                faviconUrl: faviconUrl,
                siteName: siteName,
                platform: platform,
                status: status,
                notes: notes,
                originalSharedText: originalSharedText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadataFetchedAt: metadataFetchedAt,
                metadataStatus: metadataStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                required String canonicalUrl,
                required String domain,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> localImage = const Value.absent(),
                Value<String?> faviconUrl = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<LinkPlatform> platform = const Value.absent(),
                Value<CardStatus> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> originalSharedText = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> metadataFetchedAt = const Value.absent(),
                Value<MetadataStatus> metadataStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                url: url,
                canonicalUrl: canonicalUrl,
                domain: domain,
                title: title,
                description: description,
                imageUrl: imageUrl,
                localImage: localImage,
                faviconUrl: faviconUrl,
                siteName: siteName,
                platform: platform,
                status: status,
                notes: notes,
                originalSharedText: originalSharedText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadataFetchedAt: metadataFetchedAt,
                metadataStatus: metadataStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardCategoriesRefs) db.cardCategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardCategoriesRefs)
                    await $_getPrefetchedData<Card, $CardsTable, CardCategory>(
                      currentTable: table,
                      referencedTable: $$CardsTableReferences
                          ._cardCategoriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$CardsTableReferences(
                        db,
                        table,
                        p0,
                      ).cardCategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cardId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({bool cardCategoriesRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> color,
      Value<String?> icon,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> color,
      Value<String?> icon,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardCategoriesTable, List<CardCategory>>
  _cardCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardCategories,
    aliasName: 'categories__id__card_categories__category_id',
  );

  $$CardCategoriesTableProcessedTableManager get cardCategoriesRefs {
    final manager = $$CardCategoriesTableTableManager(
      $_db,
      $_db.cardCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardCategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardCategoriesRefs(
    Expression<bool> Function($$CardCategoriesTableFilterComposer f) f,
  ) {
    final $$CardCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.cardCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> cardCategoriesRefs<T extends Object>(
    Expression<T> Function($$CardCategoriesTableAnnotationComposer a) f,
  ) {
    final $$CardCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool cardCategoriesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardCategoriesRefs) db.cardCategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardCategoriesRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      CardCategory
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._cardCategoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).cardCategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool cardCategoriesRefs})
    >;
typedef $$CardCategoriesTableCreateCompanionBuilder =
    CardCategoriesCompanion Function({
      required String cardId,
      required String categoryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardCategoriesTableUpdateCompanionBuilder =
    CardCategoriesCompanion Function({
      Value<String> cardId,
      Value<String> categoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CardCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CardCategoriesTable, CardCategory> {
  $$CardCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('card_categories__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('card_categories__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CardCategoriesTable> {
  $$CardCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardCategoriesTable> {
  $$CardCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardCategoriesTable> {
  $$CardCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardCategoriesTable,
          CardCategory,
          $$CardCategoriesTableFilterComposer,
          $$CardCategoriesTableOrderingComposer,
          $$CardCategoriesTableAnnotationComposer,
          $$CardCategoriesTableCreateCompanionBuilder,
          $$CardCategoriesTableUpdateCompanionBuilder,
          (CardCategory, $$CardCategoriesTableReferences),
          CardCategory,
          PrefetchHooks Function({bool cardId, bool categoryId})
        > {
  $$CardCategoriesTableTableManager(
    _$AppDatabase db,
    $CardCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardCategoriesCompanion(
                cardId: cardId,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String categoryId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardCategoriesCompanion.insert(
                cardId: cardId,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$CardCategoriesTableReferences
                                    ._cardIdTable(db),
                                referencedColumn:
                                    $$CardCategoriesTableReferences
                                        ._cardIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$CardCategoriesTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn:
                                    $$CardCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardCategoriesTable,
      CardCategory,
      $$CardCategoriesTableFilterComposer,
      $$CardCategoriesTableOrderingComposer,
      $$CardCategoriesTableAnnotationComposer,
      $$CardCategoriesTableCreateCompanionBuilder,
      $$CardCategoriesTableUpdateCompanionBuilder,
      (CardCategory, $$CardCategoriesTableReferences),
      CardCategory,
      PrefetchHooks Function({bool cardId, bool categoryId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CardCategoriesTableTableManager get cardCategories =>
      $$CardCategoriesTableTableManager(_db, _db.cardCategories);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
