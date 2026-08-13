import '../../links/domain/enums.dart';

/// Resultado independiente de la estrategia usada para leer una URL.
class MetadataResult {
  const MetadataResult({
    required this.status,
    this.title,
    this.description,
    this.imageUrl,
    this.faviconUrl,
    this.siteName,
    this.resolvedUrl,
  });

  final String? title;
  final String? description;
  final String? imageUrl;
  final String? faviconUrl;
  final String? siteName;

  /// URL final después de seguir redirecciones.
  final Uri? resolvedUrl;
  final MetadataStatus status;

  bool get hasUsefulContent =>
      _hasText(title) || _hasText(description) || _hasText(imageUrl);

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;
}

/// Fuente de metadata intercambiable.
///
/// La implementación directa vive en `data/`; una futura implementación con
/// proxy puede respetar este contrato sin que cambien dominio ni UI.
abstract interface class MetadataProvider {
  Future<MetadataResult> fetch(Uri url);
}
