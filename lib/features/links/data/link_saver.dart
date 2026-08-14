import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../categories/domain/category_repository.dart';
import '../../metadata/data/metadata_enrichment_service.dart';
import '../domain/enums.dart';
import '../domain/link_card.dart';
import '../domain/link_repository.dart';
import '../domain/url_normalizer.dart';

/// Punto único por el que entra un enlace a la biblioteca.
///
/// Compartir desde otra app y añadir a mano son la misma operación: normalizar,
/// comprobar duplicado, guardar y pedir la metadata sin bloquear. Tenerlo aquí
/// evita que las dos rutas se comporten distinto ante un duplicado, que es
/// justo donde se notaría.
class LinkSaver {
  LinkSaver({
    required LinkRepository links,
    required CategoryRepository categories,
    required MetadataEnrichmentService enrichment,
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _links = links,
       _categories = categories,
       _enrichment = enrichment,
       _uuid = uuid,
       _now = now ?? (() => DateTime.now().toUtc());

  final LinkRepository _links;
  final CategoryRepository _categories;
  final MetadataEnrichmentService _enrichment;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Guarda [rawUrl]. Ningún parámetro salvo la URL es obligatorio.
  ///
  /// Devuelve [InvalidUrlFailure] si el texto no contiene una URL utilizable y
  /// [DuplicateLinkFailure] con el id del existente si ya estaba guardada.
  Future<Result<LinkCard>> save({
    required String rawUrl,
    String? note,
    CardStatus status = CardStatus.pending,
    Set<String> categoryIds = const <String>{},
    String? originalSharedText,
  }) async {
    final NormalizedUrl? normalized = UrlNormalizer.normalize(rawUrl);
    if (normalized == null) {
      return const Failure<LinkCard>(InvalidUrlFailure());
    }

    final DateTime timestamp = _now();
    final String? trimmedNote = note?.trim();

    final LinkCard card = LinkCard(
      id: _uuid.v7(),
      url: normalized.original,
      canonicalUrl: normalized.canonical,
      domain: normalized.domain,
      platform: normalized.platform,
      status: status,
      notes: (trimmedNote?.isEmpty ?? true) ? null : trimmedNote,
      originalSharedText: originalSharedText,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final Result<LinkCard> result = await _links.create(card);
    if (result.failureOrNull != null) {
      return result;
    }

    if (categoryIds.isNotEmpty) {
      await _categories.setCategoriesOf(card.id, categoryIds);
    }

    // Capture first: el enlace ya está a salvo; la metadata llega cuando llega.
    unawaited(_enrichment.refreshCard(card.id));
    return Success<LinkCard>(card);
  }
}
