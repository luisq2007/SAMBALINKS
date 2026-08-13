import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/result.dart';
import '../domain/enums.dart';
import '../domain/link_card.dart';
import '../domain/link_query.dart';
import '../domain/link_repository.dart';
import 'link_card_mapper.dart';

class DriftLinkRepository implements LinkRepository {
  DriftLinkRepository(
    this._db, {
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _uuid = uuid,
       _now = now ?? (() => DateTime.now().toUtc());

  final db.AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// UUID v7: ordenable por tiempo, lo que además da un desempate estable en
  /// los listados por fecha.
  String newId() => _uuid.v7();

  @override
  Stream<List<LinkCard>> watchLinks({
    CardFilter filter = const CardFilter(),
    CardSort sort = CardSort.newest,
    int? limit,
    int offset = 0,
  }) {
    return _db.cardsDao
        .watchCards(filter: filter, sort: sort, limit: limit, offset: offset)
        .map(
          (List<db.Card> rows) =>
              rows.map((db.Card row) => row.toDomain()).toList(),
        );
  }

  @override
  Stream<int> watchCount([CardFilter filter = const CardFilter()]) =>
      _db.cardsDao.watchCount(filter);

  @override
  Stream<Map<CardStatus, int>> watchCountsByStatus() =>
      _db.cardsDao.watchCountsByStatus();

  @override
  Future<LinkCard?> findById(String id) async =>
      (await _db.cardsDao.findById(id))?.toDomain();

  @override
  Future<LinkCard?> findByCanonicalUrl(String canonicalUrl) async =>
      (await _db.cardsDao.findByCanonicalUrl(canonicalUrl))?.toDomain();

  @override
  Future<Set<String>> getLocalImagePaths() => _db.cardsDao.getLocalImagePaths();

  @override
  Future<Result<LinkCard>> create(LinkCard card) async {
    // Se comprueba antes de insertar en lugar de capturar la violación de
    // UNIQUE: así podemos devolver el id del enlace existente, que es lo que
    // el diálogo de duplicados necesita para ofrecer "Abrir card" (§27).
    final db.Card? existing = await _db.cardsDao.findByCanonicalUrl(
      card.canonicalUrl,
    );
    if (existing != null) {
      return Failure<LinkCard>(
        DuplicateLinkFailure(existingCardId: existing.id),
      );
    }

    await _db.cardsDao.upsert(card.toCompanion());
    return Success<LinkCard>(card);
  }

  @override
  Future<LinkCard> update(LinkCard card) async {
    final LinkCard touched = card.copyWith(updatedAt: _now());
    await _db.cardsDao.upsert(touched.toCompanion());
    return touched;
  }

  @override
  Future<void> updateStatus(String id, CardStatus status) async {
    final db.Card? row = await _db.cardsDao.findById(id);
    if (row == null) {
      return;
    }
    await _db.cardsDao.upsert(
      row.toDomain().copyWith(status: status, updatedAt: _now()).toCompanion(),
    );
  }

  @override
  Future<void> delete(String id) => _db.cardsDao.deleteById(id).then((_) {});
}
