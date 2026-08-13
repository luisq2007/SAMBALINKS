import '../../../core/result.dart';
import 'enums.dart';
import 'link_card.dart';
import 'link_query.dart';

/// Acceso a los enlaces guardados.
///
/// `CardFilter` y `CardSort` viven en el dominio (link_query.dart): son
/// descripciones de intención (qué quiere ver el usuario), no detalles de
/// SQLite. Es el DAO quien los importa desde aquí, y no al revés, para que el
/// dominio no arrastre Drift ni siquiera de forma transitiva.
abstract interface class LinkRepository {
  Stream<List<LinkCard>> watchLinks({
    CardFilter filter,
    CardSort sort,
    int? limit,
    int offset,
  });

  Stream<int> watchCount([CardFilter filter]);

  Stream<Map<CardStatus, int>> watchCountsByStatus();

  Future<LinkCard?> findById(String id);

  /// Busca por URL ya normalizada. Base de la detección de duplicados.
  Future<LinkCard?> findByCanonicalUrl(String canonicalUrl);

  /// Rutas relativas de imágenes que todavía pertenecen a una tarjeta.
  Future<Set<String>> getLocalImagePaths();

  /// Guarda un enlace nuevo.
  ///
  /// Devuelve [DuplicateLinkFailure] si su URL canónica ya existe, en lugar de
  /// lanzar: que el usuario comparta dos veces el mismo post es un caso
  /// esperado, no un error del programa.
  Future<Result<LinkCard>> create(LinkCard card);

  /// Actualiza un enlace existente. Refresca `updatedAt`.
  Future<LinkCard> update(LinkCard card);

  Future<void> updateStatus(String id, CardStatus status);

  Future<void> delete(String id);
}
