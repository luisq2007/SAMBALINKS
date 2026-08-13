import '../../links/domain/link_card.dart';

/// Resultado de enriquecer una tarjeta ya guardada.
sealed class MetadataRefreshOutcome {
  const MetadataRefreshOutcome();
}

class MetadataRefreshUpdated extends MetadataRefreshOutcome {
  const MetadataRefreshUpdated(this.card);

  final LinkCard card;
}

/// La URL resuelta ya pertenece a otra tarjeta.
///
/// No se fusiona ni se borra nada aquí: esa decisión requiere confirmación del
/// usuario (§27 del PRD).
class MetadataRefreshDuplicate extends MetadataRefreshOutcome {
  const MetadataRefreshDuplicate({
    required this.card,
    required this.existingCardId,
    required this.resolvedCanonicalUrl,
  });

  final LinkCard card;
  final String existingCardId;
  final String resolvedCanonicalUrl;
}

class MetadataRefreshCardNotFound extends MetadataRefreshOutcome {
  const MetadataRefreshCardNotFound(this.cardId);

  final String cardId;
}
