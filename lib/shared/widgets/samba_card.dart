import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class SambaCard extends StatefulWidget {
  const SambaCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.selected = false,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final String? semanticLabel;

  @override
  State<SambaCard> createState() => _SambaCardState();
}

class _SambaCardState extends State<SambaCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    // El foco de teclado se dibuja igual que la selección: sin un borde de
    // acento, el resalte por defecto de InkWell es un velo al 12% que sobre
    // Charcoal no se distingue, y recorrer la lista con las flechas se
    // convierte en avanzar a ciegas.
    final bool highlighted = widget.selected || _focused;
    final BorderSide border = BorderSide(
      color: highlighted
          ? theme.colorScheme.primary
          : theme.colorScheme.outline,
      width: highlighted ? 2 : 1,
    );

    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: Material(
        color: highlighted ? samba.surfaceElevated : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onFocusChange: (bool value) => setState(() => _focused = value),
          hoverColor: samba.surfaceElevated,
          borderRadius: BorderRadius.circular(Radii.card),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
