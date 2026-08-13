import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class SambaMenuItem<T> {
  const SambaMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool destructive;
}

class SambaMenu<T> extends StatelessWidget {
  const SambaMenu({
    required this.items,
    required this.onSelected,
    required this.tooltip,
    this.icon = Icons.more_horiz,
    super.key,
  });

  final List<SambaMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: Icon(icon),
      constraints: const BoxConstraints(minWidth: 220),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<T>>[
        for (final SambaMenuItem<T> item in items)
          PopupMenuItem<T>(
            value: item.value,
            height: TouchTargets.minimum,
            child: Row(
              children: <Widget>[
                Icon(
                  item.icon,
                  size: 20,
                  color: item.destructive
                      ? samba.dangerFg
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.destructive ? samba.dangerFg : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
