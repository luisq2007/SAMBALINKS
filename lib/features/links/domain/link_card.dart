import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'link_card.freezed.dart';

/// Un enlace guardado, en términos del dominio.
///
/// No conoce Drift ni Flutter: es lo que permite cambiar de persistencia o
/// añadir sincronización sin tocar la UI (§51 del PRD).
@freezed
abstract class LinkCard with _$LinkCard {
  const factory LinkCard({
    required String id,
    required String url,
    required String canonicalUrl,
    required String domain,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(LinkPlatform.other) LinkPlatform platform,
    @Default(CardStatus.pending) CardStatus status,
    @Default(MetadataStatus.pending) MetadataStatus metadataStatus,
    String? title,
    String? description,
    String? imageUrl,
    String? localImage,
    String? faviconUrl,
    String? siteName,
    String? notes,
    String? originalSharedText,
    DateTime? metadataFetchedAt,
  }) = _LinkCard;

  const LinkCard._();

  /// Texto a mostrar cuando aún no hay metadata: el dominio es mejor que un
  /// hueco vacío, y para muchas redes sociales será lo único que lleguemos a
  /// tener (§10 del PRD).
  String get displayTitle {
    final String? t = title?.trim();
    return (t == null || t.isEmpty) ? domain : t;
  }

  bool get hasPreviewImage =>
      (localImage?.isNotEmpty ?? false) || (imageUrl?.isNotEmpty ?? false);

  bool get hasNotes => notes?.trim().isNotEmpty ?? false;

  /// La metadata se puede reintentar mientras no haya dado un resultado
  /// definitivo.
  bool get canRetryMetadata =>
      metadataStatus == MetadataStatus.failed ||
      metadataStatus == MetadataStatus.pending;
}
