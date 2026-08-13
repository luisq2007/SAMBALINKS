import '../../links/domain/enums.dart';
import '../../links/domain/url_normalizer.dart';

/// Cómo llegó un contenido compartido a la aplicación.
enum ShareArrival {
  /// La app estaba cerrada y el sistema la abrió con el contenido.
  cold,

  /// La app ya estaba viva en segundo plano.
  warm,
}

/// Un contenido recibido desde la hoja de compartir del sistema.
class IncomingShare {
  const IncomingShare({
    required this.rawText,
    required this.arrival,
    required this.receivedAt,
    this.url,
    this.normalized,
  });

  /// Texto íntegro tal como lo envió la app de origen.
  /// Se conserva porque a menudo lleva contexto ("Mira esta publicación …")
  /// que el usuario puede querer recuperar.
  final String rawText;

  /// Primera URL encontrada dentro de [rawText], sin normalizar.
  final String? url;

  /// Forma canónica y plataforma deducida. `null` si el texto no traía una
  /// URL reconocible.
  final NormalizedUrl? normalized;

  final ShareArrival arrival;
  final DateTime receivedAt;

  bool get hasUrl => url != null;

  LinkPlatform get platform => normalized?.platform ?? LinkPlatform.other;

  /// La canónica de ahora es provisional porque el enlace es un acortador.
  bool get needsNetworkResolution => normalized?.needsNetworkResolution ?? false;
}
