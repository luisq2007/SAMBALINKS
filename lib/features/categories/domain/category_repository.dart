import '../../../core/result.dart';
import 'category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();

  /// Categorías con su contador de enlaces (§37 del PRD).
  Stream<List<CategorySummary>> watchAllWithCounts();

  Future<Category?> findById(String id);

  /// Crea una categoría. Devuelve [DuplicateCategoryFailure] si el nombre ya
  /// existe, y [ValidationFailure] si está vacío.
  Future<Result<Category>> create({
    required String name,
    String? color,
    String? icon,
  });

  Future<Category> update(Category category);

  /// Borra la categoría y sus relaciones. **Nunca borra enlaces.**
  Future<void> delete(String id);

  Future<void> reorder(List<String> orderedIds);

  // --- Relación con enlaces ---

  Stream<List<Category>> watchCategoriesOf(String cardId);

  /// Añade el enlace a una categoría. Idempotente.
  Future<void> assign({required String cardId, required String categoryId});

  Future<void> unassign({required String cardId, required String categoryId});

  /// Reemplaza el conjunto completo de categorías de un enlace.
  Future<void> setCategoriesOf(String cardId, Set<String> categoryIds);
}
