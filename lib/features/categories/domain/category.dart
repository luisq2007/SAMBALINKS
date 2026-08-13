import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Categoría creada por el usuario.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int sortOrder,

    /// Hex de la paleta, p. ej. "#B9ECFA".
    String? color,

    /// Clave de un catálogo propio de iconos, nunca un codePoint.
    String? icon,
  }) = _Category;

  const Category._();
}

/// Una categoría con su número de enlaces, para la barra lateral.
@freezed
abstract class CategorySummary with _$CategorySummary {
  const factory CategorySummary({
    required Category category,
    required int linkCount,
  }) = _CategorySummary;

  const CategorySummary._();
}
