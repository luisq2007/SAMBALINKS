import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../backup/presentation/backup_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        Text(
          l10n.navSettings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.xl),
        const BackupSection(),
      ],
    );
  }
}
