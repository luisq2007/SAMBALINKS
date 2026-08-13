import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/enums.dart';
import '../domain/link_card.dart';

/// Traducción entre la fila de Drift y la entidad de dominio.
///
/// Es el único punto del proyecto donde ambos mundos se tocan.
extension CardRowToDomain on db.Card {
  LinkCard toDomain() {
    return LinkCard(
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
    );
  }
}

extension LinkCardToRow on LinkCard {
  db.CardsCompanion toCompanion() {
    return db.CardsCompanion.insert(
      id: id,
      url: url,
      canonicalUrl: canonicalUrl,
      domain: domain,
      title: Value<String?>(title),
      description: Value<String?>(description),
      imageUrl: Value<String?>(imageUrl),
      localImage: Value<String?>(localImage),
      faviconUrl: Value<String?>(faviconUrl),
      siteName: Value<String?>(siteName),
      platform: Value<LinkPlatform>(platform),
      status: Value<CardStatus>(status),
      notes: Value<String?>(notes),
      originalSharedText: Value<String?>(originalSharedText),
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadataFetchedAt: Value<DateTime?>(metadataFetchedAt),
      metadataStatus: Value<MetadataStatus>(metadataStatus),
    );
  }
}
