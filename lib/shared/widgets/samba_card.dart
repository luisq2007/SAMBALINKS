import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class SambaCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    final BorderSide border = BorderSide(
      color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
      width: selected ? 2 : 1,
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: selected ? samba.surfaceElevated : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: samba.surfaceElevated,
          borderRadius: BorderRadius.circular(Radii.card),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
