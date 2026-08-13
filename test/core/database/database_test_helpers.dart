import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

/// Construye un enlace con valores por defecto razonables para que cada test
/// declare únicamente lo que le importa.
CardsCompanion buildCard({
  String? id,
  String? url,
  String? canonicalUrl,
  String domain = 'ejemplo.com',
  String? title,
  String? description,
  String? imageUrl,
  String? notes,
  LinkPlatform platform = LinkPlatform.web,
  CardStatus status = CardStatus.pending,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final String cardId = id ?? _uuid.v7();
  final String finalUrl = url ?? 'https://$domain/$cardId';
  final DateTime now = createdAt ?? DateTime.utc(2026, 8, 12, 12);

  return CardsCompanion.insert(
    id: cardId,
    url: finalUrl,
    canonicalUrl: canonicalUrl ?? finalUrl,
    domain: domain,
    title: Value<String?>(title),
    description: Value<String?>(description),
    imageUrl: Value<String?>(imageUrl),
    notes: Value<String?>(notes),
    platform: Value<LinkPlatform>(platform),
    status: Value<CardStatus>(status),
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

CategoriesCompanion buildCategory({
  String? id,
  required String name,
  int sortOrder = 0,
  DateTime? createdAt,
}) {
  final DateTime now = createdAt ?? DateTime.utc(2026, 8, 12, 12);
  return CategoriesCompanion.insert(
    id: id ?? _uuid.v7(),
    name: name,
    sortOrder: Value<int>(sortOrder),
    createdAt: now,
    updatedAt: now,
  );
}
