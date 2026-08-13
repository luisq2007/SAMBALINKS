import '../domain/metadata_provider.dart';

/// Paso opcional de la cadena de extracción.
abstract interface class MetadataStrategy {
  Future<MetadataResult?> fetch(Uri url);
}
