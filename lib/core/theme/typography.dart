import 'package:flutter/material.dart';

/// Escala tipográfica geométrica de SambaLinks.
///
/// Usa la sans del sistema para no descargar fuentes ni romper el arranque sin
/// conexión. En Android se resuelve a Roboto y en plataformas Apple a SF Pro.
abstract final class SambaTypography {
  static TextTheme build(Color color) {
    const String family = 'sans-serif';
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: family,
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      headlineSmall: TextStyle(
        fontFamily: family,
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: color,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: color,
      ),
    );
  }
}
