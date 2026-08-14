import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/result.dart';
import '../../core/theme/tokens.dart';
import '../../features/links/domain/link_card.dart';
import '../../features/links/domain/url_extractor.dart';

/// Permite arrastrar enlaces desde el navegador hasta la ventana.
///
/// Es **la ruta de captura en escritorio** (riesgo R3 del plan):
/// `receive_sharing_intent` no soporta macOS, así que sin esto la única forma
/// de guardar algo fuera del móvil sería teclear la URL a mano.
class LinkDropTarget extends ConsumerStatefulWidget {
  const LinkDropTarget({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LinkDropTarget> createState() => _LinkDropTargetState();
}

class _LinkDropTargetState extends ConsumerState<LinkDropTarget> {
  bool _hovering = false;

  /// Sólo escritorio: en móvil no hay nada que arrastrar desde fuera.
  bool get _enabled =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  Future<void> _onDrop(DropDoneDetails details) async {
    setState(() => _hovering = false);
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // Un arrastre desde el navegador llega como texto con la URL dentro; uno
    // desde el escritorio, como fichero. Interesa lo primero.
    final List<String> urls = <String>[
      for (final DropItem item in details.files)
        if (extractFirstUrl(item.path) case final String url) url,
    ];

    if (urls.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dropNothingUseful)));
      return;
    }

    int saved = 0;
    for (final String url in urls) {
      final Result<LinkCard> result = await ref
          .read(linkSaverProvider)
          .save(rawUrl: url);
      if (result.isSuccess) {
        saved++;
      }
    }

    if (!mounted) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved == 0 ? l10n.addLinkDuplicateTitle : l10n.dropSaved(saved),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) {
      return widget.child;
    }

    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return DropTarget(
      onDragEntered: (_) => setState(() => _hovering = true),
      onDragExited: (_) => setState(() => _hovering = false),
      onDragDone: (DropDoneDetails details) => unawaited(_onDrop(details)),
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_hovering)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(Radii.card),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.add_link,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: Spacing.md),
                          Text(
                            l10n.dropHint,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
