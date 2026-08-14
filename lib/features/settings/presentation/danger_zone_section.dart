import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart'
    show SambaButton, SambaButtonVariant, SambaTextField;
import '../../links/domain/enums.dart';

/// Borrado total de la biblioteca, con doble confirmación.
class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.dangerZone,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.clearLibraryDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: SambaButton(
            variant: SambaButtonVariant.danger,
            icon: Icons.delete_forever_outlined,
            onPressed: () => unawaited(_confirm(context, ref)),
            label: l10n.clearLibrary,
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Map<CardStatus, int> counts =
        ref.read(statusCountsProvider).asData?.value ??
        const <CardStatus, int>{};
    final int cards = counts.values.fold(0, (int a, int b) => a + b);
    final int categories =
        ref.read(categoriesProvider).asData?.value.length ?? 0;

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) =>
              _ClearLibraryDialog(cards: cards, categories: categories),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await ref.read(libraryBackupServiceProvider).clearLibrary();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.clearLibraryDone)));
  }
}

/// Pide escribir la palabra de confirmación.
///
/// Un botón "¿Seguro?" se pulsa por inercia; escribir BORRAR obliga a leer lo
/// que se va a perder. Es la única acción de la app que no se puede deshacer.
class _ClearLibraryDialog extends StatefulWidget {
  const _ClearLibraryDialog({required this.cards, required this.categories});

  final int cards;
  final int categories;

  @override
  State<_ClearLibraryDialog> createState() => _ClearLibraryDialogState();
}

class _ClearLibraryDialogState extends State<_ClearLibraryDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_outlined,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(l10n.clearLibraryConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.clearLibraryConfirmBody(widget.cards, widget.categories)),
          const SizedBox(height: Spacing.lg),
          SambaTextField(
            controller: _controller,
            label: l10n.clearLibraryTypeToConfirm,
            hint: l10n.clearLibraryKeyword,
            onChanged: (String value) => setState(
              () => _matches = value.trim() == l10n.clearLibraryKeyword,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.clearLibrary),
        ),
      ],
    );
  }
}
