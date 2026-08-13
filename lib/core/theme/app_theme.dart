import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

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
    final TextTheme textTheme = SambaTypography.build(scheme.onSurface);

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: scheme.outline),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: extension.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      visualDensity: VisualDensity.standard,
    );
  }
}
