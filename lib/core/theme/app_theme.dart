import 'package:flutter/material.dart';

import 'tokens.dart';

/// Temas claro y oscuro de SambaLinks.
///
/// El oscuro no es el claro invertido: cambia la jerarquía de superficies
/// (Raven de fondo, Charcoal de tarjeta, Lagoon de elevación) y el acento pasa
/// de Lagoon a Arctic, porque Lagoon sobre Charcoal sólo alcanza 1.6:1.
abstract final class AppTheme {
  static ThemeData get light => _build(
    scheme: const ColorScheme.light(
      primary: SambaPalette.lagoon,
      onPrimary: SambaPalette.white,
      secondary: SambaPalette.evergreen,
      onSecondary: SambaPalette.white,
      surface: SambaPalette.white,
      onSurface: SambaPalette.raven,
      onSurfaceVariant: SambaPalette.charcoal,
      outline: Color(0x1F061E29),
    ),
    scaffoldBackground: SambaPalette.offWhite,
    extension: SambaColors.light,
  );

  static ThemeData get dark => _build(
    scheme: const ColorScheme.dark(
      primary: SambaPalette.arctic,
      onPrimary: SambaPalette.raven,
      secondary: SambaPalette.mint,
      onSecondary: SambaPalette.raven,
      surface: SambaPalette.charcoal,
      onSurface: SambaPalette.white,
      onSurfaceVariant: SambaPalette.slate,
      outline: Color(0x1FFFFFFF),
    ),
    scaffoldBackground: SambaPalette.raven,
    extension: SambaColors.dark,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required SambaColors extension,
  }) {
    final ThemeData base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: <ThemeExtension<dynamic>>[extension],
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
    );
  }
}
