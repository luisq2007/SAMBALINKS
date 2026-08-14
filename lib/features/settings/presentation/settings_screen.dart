import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../backup/presentation/backup_section.dart';
import 'appearance_section.dart';
import 'danger_zone_section.dart';

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
        const AppearanceSection(),
        const _Separator(),
        const BackupSection(),
        const _Separator(),
        const _AboutSection(),
        const _Separator(),
        const DangerZoneSection(),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: Spacing.xl),
    child: Divider(height: 1),
  );
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.settingsAbout, style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final String version = snapshot.data?.version ?? '—';
            return Text(
              l10n.aboutVersion(version),
              style: theme.textTheme.bodyMedium,
            );
          },
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.aboutPrivacy,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
