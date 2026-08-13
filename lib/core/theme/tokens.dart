import 'package:flutter/material.dart';

/// Paleta de marca de SambaLinks.
///
/// Los cuatro tonos oscuros y los cuatro claros se corresponden por posición:
/// Charcoal→White, Lagoon→Arctic, Evergreen→Mint, Raven→Sand.
///
/// Ningún widget debe declarar un `Color(0x...)` propio: todo color sale de
/// aquí o de `ColorScheme` / `SambaColors`.
abstract final class SambaPalette {
  // Tonos oscuros
  static const Color raven = Color(0xFF061E29);
  static const Color charcoal = Color(0xFF18343F);
  static const Color lagoon = Color(0xFF0D4C5C);
  static const Color evergreen = Color(0xFF0D514F);

  // Tonos claros
  static const Color white = Color(0xFFFFFFFF);
  static const Color arctic = Color(0xFFB9ECFA);
  static const Color mint = Color(0xFFB9F7D8);
  static const Color sand = Color(0xFFFFF0BD);

  // Neutros derivados.
  // offWhite evita el blanco puro como fondo de toda la app: White queda
  // reservado para superficies y tarjetas, que así se despegan del fondo.
  static const Color offWhite = Color(0xFFF4F7F8);

  // Texto secundario sobre superficies oscuras: 6.86:1 sobre Charcoal (AA).
  static const Color slate = Color(0xFFA9BFC9);

  // Variantes de estado legibles sobre sus respectivos fondos.
  static const Color amberInk = Color(0xFFB98900); // sobre Sand
  static const Color amberGlow = Color(0xFFFFD666); // sobre Charcoal/Raven
  static const Color aquaGlow = Color(0xFF6FD8F0);
  static const Color jadeInk = Color(0xFF12795A); // sobre Mint
  static const Color jadeGlow = Color(0xFF5FDCA4);

  // Acciones destructivas y sus superficies de bajo énfasis.
  static const Color coral = Color(0xFFB42318);
  static const Color coralGlow = Color(0xFFFFB4AB);
  static const Color coralSurface = Color(0xFFFFEDEA);
  static const Color coralSurfaceDark = Color(0x33FFB4AB);

  /// Opciones persistibles del selector de categorías. La clave hexadecimal
  /// viaja en la base/JSON y el valor mantiene el color centralizado aquí.
  static const Map<String, Color> categoryChoices = <String, Color>{
    '#B9ECFA': arctic,
    '#B9F7D8': mint,
    '#FFF0BD': sand,
    '#0D4C5C': lagoon,
    '#0D514F': evergreen,
    '#18343F': charcoal,
  };

  /// Convierte colores configurables de categoría sin introducir literales
  /// dentro de widgets. Sólo admite RGB en formato `#RRGGBB`.
  static Color? tryParseHex(String? hex) {
    if (hex == null || !hex.startsWith('#') || hex.length != 7) {
      return null;
    }
    final int? value = int.tryParse(hex.substring(1), radix: 16);
    return value == null
        ? null
        : Color.fromARGB(
            255,
            (value >> 16) & 0xFF,
            (value >> 8) & 0xFF,
            value & 0xFF,
          );
  }
}

/// Colores semánticos que `ColorScheme` no sabe expresar.
@immutable
class SambaColors extends ThemeExtension<SambaColors> {
  const SambaColors({
    required this.surfaceElevated,
    required this.pendingFg,
    required this.pendingBg,
    required this.activeFg,
    required this.activeBg,
    required this.doneFg,
    required this.doneBg,
    required this.dangerFg,
    required this.dangerBg,
  });

  /// Hover, seleccionado, sidebar activo. En oscuro sustituye a la sombra,
  /// que sobre fondo oscuro no se percibe.
  final Color surfaceElevated;

  final Color pendingFg;
  final Color pendingBg;
  final Color activeFg;
  final Color activeBg;
  final Color doneFg;
  final Color doneBg;
  final Color dangerFg;
  final Color dangerBg;

  static const SambaColors light = SambaColors(
    surfaceElevated: Color(0xFFE9EFF2),
    pendingFg: SambaPalette.amberInk,
    pendingBg: SambaPalette.sand,
    activeFg: SambaPalette.lagoon,
    activeBg: SambaPalette.arctic,
    doneFg: SambaPalette.jadeInk,
    doneBg: SambaPalette.mint,
    dangerFg: SambaPalette.coral,
    dangerBg: SambaPalette.coralSurface,
  );

  static const SambaColors dark = SambaColors(
    surfaceElevated: SambaPalette.lagoon,
    pendingFg: SambaPalette.amberGlow,
    pendingBg: Color(0x33FFD666),
    activeFg: SambaPalette.aquaGlow,
    activeBg: Color(0x336FD8F0),
    doneFg: SambaPalette.jadeGlow,
    doneBg: Color(0x335FDCA4),
    dangerFg: SambaPalette.coralGlow,
    dangerBg: SambaPalette.coralSurfaceDark,
  );

  @override
  SambaColors copyWith({
    Color? surfaceElevated,
    Color? pendingFg,
    Color? pendingBg,
    Color? activeFg,
    Color? activeBg,
    Color? doneFg,
    Color? doneBg,
    Color? dangerFg,
    Color? dangerBg,
  }) {
    return SambaColors(
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      pendingFg: pendingFg ?? this.pendingFg,
      pendingBg: pendingBg ?? this.pendingBg,
      activeFg: activeFg ?? this.activeFg,
      activeBg: activeBg ?? this.activeBg,
      doneFg: doneFg ?? this.doneFg,
      doneBg: doneBg ?? this.doneBg,
      dangerFg: dangerFg ?? this.dangerFg,
      dangerBg: dangerBg ?? this.dangerBg,
    );
  }

  @override
  SambaColors lerp(ThemeExtension<SambaColors>? other, double t) {
    if (other is! SambaColors) {
      return this;
    }
    return SambaColors(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      pendingFg: Color.lerp(pendingFg, other.pendingFg, t)!,
      pendingBg: Color.lerp(pendingBg, other.pendingBg, t)!,
      activeFg: Color.lerp(activeFg, other.activeFg, t)!,
      activeBg: Color.lerp(activeBg, other.activeBg, t)!,
      doneFg: Color.lerp(doneFg, other.doneFg, t)!,
      doneBg: Color.lerp(doneBg, other.doneBg, t)!,
      dangerFg: Color.lerp(dangerFg, other.dangerFg, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }
}

/// Escala de espaciado en múltiplos de 4.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Radios de esquina.
abstract final class Radii {
  static const double chip = 8;
  static const double card = 12;
  static const double sheet = 16;
}

/// Duraciones compartidas. Los widgets consultan además
/// `MediaQuery.disableAnimations` antes de animar.
abstract final class MotionDurations {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration transition = Duration(milliseconds: 220);
  static const Duration panel = Duration(milliseconds: 320);
}

abstract final class MotionCurves {
  static const Curve standard = Curves.easeOutCubic;
}

abstract final class TouchTargets {
  static const double minimum = 44;
}
