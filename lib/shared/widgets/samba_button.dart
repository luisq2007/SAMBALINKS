import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

enum SambaButtonVariant { primary, secondary, ghost, danger }

class SambaButton extends StatelessWidget {
  const SambaButton({
    required this.label,
    required this.onPressed,
    this.variant = SambaButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SambaButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    final VoidCallback? effectiveAction = loading ? null : onPressed;
    final Widget content = _ButtonContent(
      label: label,
      icon: icon,
      loading: loading,
    );
    final ButtonStyle style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(TouchTargets.minimum, TouchTargets.minimum),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.chip)),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(theme.textTheme.labelLarge),
    );

    final Widget button = switch (variant) {
      SambaButtonVariant.primary => FilledButton(
        onPressed: effectiveAction,
        style: style,
        child: content,
      ),
      SambaButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveAction,
        style: style,
        child: content,
      ),
      SambaButtonVariant.ghost => TextButton(
        onPressed: effectiveAction,
        style: style,
        child: content,
      ),
      SambaButtonVariant.danger => FilledButton(
        onPressed: effectiveAction,
        style: style.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.disabled)
                ? null
                : samba.dangerBg;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(samba.dangerFg),
        ),
        child: content,
      ),
    };

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(width: expand ? double.infinity : null, child: button),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
  });

  final String label;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (loading)
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (loading || icon != null) const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
