import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return EmptyState(
      icon: Icons.settings_outlined,
      title: l10n.settingsPlaceholderTitle,
      body: l10n.settingsPlaceholderBody,
    );
  }
}
