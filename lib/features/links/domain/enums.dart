/// Estado de un enlace en el flujo de trabajo del usuario.
///
/// Se persiste como TEXTO, nunca como índice ordinal: reordenar el enum no
/// puede corromper la base de datos y el JSON exportado es legible.
/// La columna no lleva `CHECK`, para permitir estados personalizados más
/// adelante (§12 del PRD) sin migración de esquema.
enum CardStatus {
  pending('pending'),
  active('active'),
  done('done');

  const CardStatus(this.value);

  final String value;

  static CardStatus fromValue(String value) {
    return CardStatus.values.firstWhere(
      (CardStatus s) => s.value == value,
      orElse: () => CardStatus.pending,
    );
  }
}

/// Resultado del intento de obtener metadata de la URL.
enum MetadataStatus {
  /// Aún no se ha intentado.
  pending('pending'),

  /// Se obtuvo título, descripción e imagen.
  ok('ok'),

  /// Sólo se pudo determinar plataforma y dominio. Es el caso habitual en
  /// Instagram, X, Facebook y LinkedIn (§10 del PRD), no un error.
  partial('partial'),

  /// La petición falló y se puede reintentar.
  failed('failed'),

  /// El esquema o el destino no admiten metadata.
  unsupported('unsupported');

  const MetadataStatus(this.value);

  final String value;

  static MetadataStatus fromValue(String value) {
    return MetadataStatus.values.firstWhere(
      (MetadataStatus s) => s.value == value,
      orElse: () => MetadataStatus.pending,
    );
  }
}

/// Plataforma de origen del enlace, deducida del dominio.
enum LinkPlatform {
  instagram('instagram'),
  x('x'),
  threads('threads'),
  pinterest('pinterest'),
  facebook('facebook'),
  tiktok('tiktok'),
  youtube('youtube'),
  linkedin('linkedin'),
  reddit('reddit'),
  web('web'),
  other('other');

  const LinkPlatform(this.value);

  final String value;

  static LinkPlatform fromValue(String value) {
    return LinkPlatform.values.firstWhere(
      (LinkPlatform p) => p.value == value,
      orElse: () => LinkPlatform.other,
    );
  }
}
