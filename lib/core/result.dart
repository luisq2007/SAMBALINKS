/// Fallos que la aplicación espera y sabe explicar al usuario.
///
/// No cubren errores de programación: esos deben propagarse como excepciones
/// para que aparezcan en desarrollo, no convertirse en un `Result` silencioso.
sealed class AppFailure {
  const AppFailure();
}

/// Ya existe un enlace con la misma URL canónica (§27 del PRD).
class DuplicateLinkFailure extends AppFailure {
  const DuplicateLinkFailure({required this.existingCardId});

  final String existingCardId;
}

/// Ya existe una categoría con ese nombre.
class DuplicateCategoryFailure extends AppFailure {
  const DuplicateCategoryFailure({required this.existingCategoryId});

  final String existingCategoryId;
}

/// Entrada del usuario que no supera la validación.
class ValidationFailure extends AppFailure {
  const ValidationFailure(this.message);

  final String message;
}

/// Resultado de una operación que puede fallar de forma prevista.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// Valor en caso de éxito, `null` si falló.
  T? get valueOrNull => switch (this) {
    Success<T>(:final T value) => value,
    Failure<T>() => null,
  };

  /// Fallo en caso de error, `null` si tuvo éxito.
  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final AppFailure failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final T value) => onSuccess(value),
      Failure<T>(:final AppFailure failure) => onFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}
