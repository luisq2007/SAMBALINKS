/// Clases de ventana que gobiernan la navegación adaptativa de SambaLinks.
enum SambaWindowClass { mobile, tablet, desktop, wideDesktop }

abstract final class SambaBreakpoints {
  /// Móvil: ancho menor de 600 px.
  static const double tablet = 600;

  /// Tablet: desde 600 hasta 1024 px, ambos inclusive.
  static const double desktop = 1024;

  /// En escritorio mayor de 1400 px aparece el panel de detalle.
  static const double detailPane = 1400;

  static SambaWindowClass fromWidth(double width) {
    if (width < tablet) {
      return SambaWindowClass.mobile;
    }
    if (width <= desktop) {
      return SambaWindowClass.tablet;
    }
    if (width <= detailPane) {
      return SambaWindowClass.desktop;
    }
    return SambaWindowClass.wideDesktop;
  }
}
