import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';

/// Selector de apariencia (§36 del PRD). Por defecto **Sistema**.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final ThemeMode mode =
        ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.settingsAppearance, style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.appearanceDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.md),
        RadioGroup<ThemeMode>(
          groupValue: mode,
          onChanged: (ThemeMode? value) =>
              unawaited(ref.read(themeModeProvider.notifier).setMode(value!)),
          child: Column(
            children: <Widget>[
              for (final (ThemeMode value, String label)
                  in <(ThemeMode, String)>[
                    (ThemeMode.system, l10n.themeSystem),
                    (ThemeMode.light, l10n.themeLight),
                    (ThemeMode.dark, l10n.themeDark),
                  ])
                RadioListTile<ThemeMode>(
                  value: value,
                  title: Text(label),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
