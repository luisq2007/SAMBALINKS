import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../features/links/domain/enums.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    final (String label, Color foreground, Color background) value =
        switch (status) {
          CardStatus.pending => (
            l10n.statusPending,
            samba.pendingFg,
            samba.pendingBg,
          ),
          CardStatus.active => (
            l10n.statusActive,
            samba.activeFg,
            samba.activeBg,
          ),
          CardStatus.done => (l10n.statusDone, samba.doneFg, samba.doneBg),
        };

    return Semantics(
      label: value.$1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: value.$3,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.circle, size: 8, color: value.$2),
            const SizedBox(width: Spacing.sm),
            Text(
              value.$1,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: value.$2),
            ),
          ],
        ),
      ),
    );
  }
}
