import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../features/categories/domain/category.dart';
import '../category_icon_catalog.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    this.selected = false,
    this.onPressed,
    this.onDeleted,
    super.key,
  });

  final Category category;
  final bool selected;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        SambaPalette.tryParseHex(category.color) ?? theme.colorScheme.surface;
    final Color foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? SambaPalette.white
        : SambaPalette.raven;

    return Semantics(
      button: onPressed != null,
      selected: selected,
      child: Material(
        color: selected ? background : background.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.chip),
          side: BorderSide(
            color: selected ? foreground : theme.colorScheme.outline,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Radii.chip),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TouchTargets.minimum),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    CategoryIconCatalog.fromKey(category.icon),
                    size: 18,
                    color: foreground,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    category.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                  if (onDeleted != null) ...<Widget>[
                    const SizedBox(width: Spacing.xs),
                    IconButton(
                      onPressed: onDeleted,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minHeight: TouchTargets.minimum,
                        minWidth: TouchTargets.minimum,
                      ),
                      color: foreground,
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
