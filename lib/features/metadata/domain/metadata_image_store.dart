/// Resultado de una pasada de limpieza de imágenes locales.
class OrphanImageCleanupResult {
  const OrphanImageCleanupResult({
    required this.scanned,
    required this.deleted,
    required this.timedOut,
  });

  final int scanned;
  final int deleted;
  final bool timedOut;
}

/// Persistencia no evictable de imágenes de vista previa.
abstract interface class MetadataImageStore {
  /// Descarga una imagen y devuelve su ruta relativa al directorio de soporte.
  ///
  /// Devuelve `null` cuando la respuesta no es una imagen válida, excede el
  /// límite o falla la red. La metadata textual debe sobrevivir a esos casos.
  Future<String?> persist({required String cardId, required Uri imageUrl});

  Future<void> delete(String relativePath);

  Future<OrphanImageCleanupResult> cleanupOrphans(
    Set<String> referencedPaths, {
    Duration timeLimit = const Duration(milliseconds: 250),
  });
}
