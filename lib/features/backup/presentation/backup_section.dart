import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart'
    show SambaButton, SambaButtonVariant;
import '../../links/domain/enums.dart';
import '../data/library_backup_service.dart';
import '../domain/library_snapshot.dart';

/// Sección "Datos" de Ajustes: exportar e importar la biblioteca (§28 del PRD).
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final String json = await ref.read(libraryBackupServiceProvider).exportJson();
      final Directory dir = await getTemporaryDirectory();
      final String stamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final File file = File('${dir.path}/sambalinks-$stamp.json');
      await file.writeAsString(json);

      // §31: tras exportar se abre la hoja de compartir del sistema, para que
      // el archivo pueda ir a AirDrop, Drive, correo o donde el usuario quiera
      // sin que SambaLinks se integre con ninguno.
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(file.path)]),
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportDone)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportError)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _import() async {
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    const XTypeGroup group = XTypeGroup(
      label: 'SambaLinks',
      extensions: <String>['json'],
    );
    final XFile? picked = await openFile(acceptedTypeGroups: <XTypeGroup>[group]);
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _busy = true);
    final LibraryBackupService service = ref.read(libraryBackupServiceProvider);

    LibrarySnapshot snapshot;
    try {
      snapshot = service.parseBytes(await picked.readAsBytes());
    } on UnsupportedSchemaVersion {
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.importErrorVersion)));
      return;
    } on Object {
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importErrorMalformed)),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    final _ImportChoice? choice = await showDialog<_ImportChoice>(
      context: context,
      builder: (BuildContext context) => _ImportDialog(snapshot: snapshot),
    );
    if (choice == null || !mounted) {
      return;
    }

    setState(() => _busy = true);
    try {
      final ImportReport report = await service.import(
        snapshot,
        mode: choice.mode,
        duplicates: choice.duplicates,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.importDone(
              report.cardsAdded,
              report.cardsUpdated,
              report.cardsSkipped,
            ),
          ),
        ),
      );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importError)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.settingsData, style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.md),

        Text(l10n.exportDescription, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Spacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: SambaButton(
            icon: Icons.ios_share,
            onPressed: _busy ? null : () => unawaited(_export()),
            label: l10n.exportLibrary,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.exportImagesNotice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: Spacing.xl),
        Text(l10n.importDescription, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Spacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: SambaButton(
            variant: SambaButtonVariant.secondary,
            icon: Icons.file_open_outlined,
            onPressed: _busy ? null : () => unawaited(_import()),
            label: l10n.importPick,
          ),
        ),
      ],
    );
  }
}

class _ImportChoice {
  const _ImportChoice({required this.mode, required this.duplicates});

  final ImportMode mode;
  final DuplicatePolicy duplicates;
}

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog({required this.snapshot});

  final LibrarySnapshot snapshot;

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  ImportMode _mode = ImportMode.merge;
  DuplicatePolicy _duplicates = DuplicatePolicy.keepExisting;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final Map<CardStatus, int> counts =
        ref.watch(statusCountsProvider).asData?.value ??
        const <CardStatus, int>{};
    final int currentCards = counts.values.fold(0, (int a, int b) => a + b);
    final int currentCategories =
        ref.watch(categoriesProvider).asData?.value.length ?? 0;

    return AlertDialog(
      title: Text(l10n.importConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.importSummary(
                widget.snapshot.cards.length,
                widget.snapshot.categories.length,
              ),
            ),
            const SizedBox(height: Spacing.lg),

            Text(l10n.importModeLabel, style: theme.textTheme.labelLarge),
            RadioGroup<ImportMode>(
              groupValue: _mode,
              onChanged: (ImportMode? value) => setState(() => _mode = value!),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<ImportMode>(
                    value: ImportMode.merge,
                    title: Text(l10n.importMerge),
                    subtitle: Text(l10n.importMergeDescription),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<ImportMode>(
                    value: ImportMode.replace,
                    title: Text(l10n.importReplace),
                    subtitle: Text(l10n.importReplaceDescription),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // §30: antes de Reemplazar, confirmación obligatoria con el
            // recuento de lo que se va a perder.
            if (_mode == ImportMode.replace) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Text(
                  l10n.importReplaceWarning(currentCards, currentCategories),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],

            if (_mode == ImportMode.merge) ...<Widget>[
              const SizedBox(height: Spacing.lg),
              Text(
                l10n.importDuplicatesLabel,
                style: theme.textTheme.labelLarge,
              ),
              RadioGroup<DuplicatePolicy>(
                groupValue: _duplicates,
                onChanged: (DuplicatePolicy? value) =>
                    setState(() => _duplicates = value!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final (DuplicatePolicy policy, String label)
                        in <(DuplicatePolicy, String)>[
                          (
                            DuplicatePolicy.keepExisting,
                            l10n.importKeepExisting,
                          ),
                          (
                            DuplicatePolicy.replaceWithImported,
                            l10n.importReplaceWithImported,
                          ),
                          (DuplicatePolicy.keepNewest, l10n.importKeepNewest),
                        ])
                      RadioListTile<DuplicatePolicy>(
                        value: policy,
                        title: Text(label),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _ImportChoice(mode: _mode, duplicates: _duplicates),
          ),
          child: Text(l10n.importConfirm),
        ),
      ],
    );
  }
}
