/// Cómo llegó un contenido compartido a la aplicación.
enum ShareArrival {
  /// La app estaba cerrada y el sistema la abrió con el contenido.
  cold,

  /// La app ya estaba viva en segundo plano.
  warm,
}

/// Un contenido recibido desde la hoja de compartir del sistema.
///
/// Es deliberadamente crudo: guardar primero, interpretar después. La
/// normalización de la URL y la obtención de metadata llegan en fases
/// posteriores.
class IncomingShare {
  const IncomingShare({
    required this.rawText,
    required this.url,
    required this.arrival,
    required this.receivedAt,
  });

  /// Texto íntegro tal como lo envió la app de origen.
  /// Se conserva porque a menudo lleva contexto ("Mira esta publicación …")
  /// que el usuario puede querer recuperar.
  final String rawText;

  /// Primera URL encontrada dentro de [rawText], si la hay.
  final String? url;

  final ShareArrival arrival;
  final DateTime receivedAt;

  bool get hasUrl => url != null;
}
