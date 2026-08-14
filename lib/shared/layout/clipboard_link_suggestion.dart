import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../features/links/domain/link_card.dart';
import '../../features/links/domain/url_extractor.dart';
import '../../features/links/domain/url_normalizer.dart';
import '../../features/links/presentation/add_link_sheet.dart';

/// Sugiere guardar el enlace que hay en el portapapeles al volver a la ventana.
///
/// **Sólo escritorio, y por la misma razón que la F9.5 rechazó leer el
/// portapapeles al abrir la hoja en móvil:** Android avisa con un mensaje del
/// sistema cada vez que una app lo lee, y una app que fisgonea sola contradice
/// el "Privacy First" del producto. En macOS no hay tal aviso y el gesto
/// natural del escritorio es copiar la URL de la barra del navegador, así que
/// aquí la sugerencia ayuda en lugar de incomodar.
///
/// La sugerencia es pasiva: una tarjeta en una esquina que no roba el foco, no
/// bloquea nada y desaparece al descartarla. Nunca guarda por su cuenta.
class ClipboardLinkSuggestion extends ConsumerStatefulWidget {
  const ClipboardLinkSuggestion({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ClipboardLinkSuggestion> createState() =>
      _ClipboardLinkSuggestionState();
}

class _ClipboardLinkSuggestionState
    extends ConsumerState<ClipboardLinkSuggestion> {
  AppLifecycleListener? _lifecycle;

  /// URLs ya ofrecidas o descartadas. Sin esto la misma sugerencia reaparece
  /// cada vez que la ventana recupera el foco, que es exactamente el tipo de
  /// insistencia que el PRD llama intrusiva.
  final Set<String> _handled = <String>{};

  String? _suggestion;

  /// Se consulta `defaultTargetPlatform` y no `Platform.isMacOS` porque el
  /// primero se puede sustituir en un test: la garantía de que en móvil no se
  /// lee el portapapeles tiene que ser comprobable, no una promesa.
  static bool get _enabled =>
      !kIsWeb &&
      const <TargetPlatform>{
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    if (_enabled) {
      _lifecycle = AppLifecycleListener(
        onRestart: () => unawaited(_check()),
        onShow: () => unawaited(_check()),
      );
      unawaited(_check());
    }
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? url = extractFirstUrl(data?.text ?? '');
    if (url == null || _handled.contains(url)) {
      return;
    }

    // Ofrecer guardar algo que ya está guardado es ruido, no ayuda.
    final NormalizedUrl? normalized = UrlNormalizer.normalize(url);
    if (normalized == null) {
      return;
    }
    final LinkCard? existing = await ref
        .read(linkRepositoryProvider)
        .findByCanonicalUrl(normalized.canonical);

    if (!mounted || existing != null) {
      return;
    }
    setState(() => _suggestion = url);
  }

  void _dismiss() {
    final String? url = _suggestion;
    setState(() {
      if (url != null) {
        _handled.add(url);
      }
      _suggestion = null;
    });
  }

  Future<void> _save() async {
    final String? url = _suggestion;
    if (url == null) {
      return;
    }
    _dismiss();
    await AddLinkSheet.show(context, initialUrl: url);
  }

  @override
  Widget build(BuildContext context) {
    final String? url = _suggestion;
    if (!_enabled || url == null) {
      return widget.child;
    }

    return Stack(
      // expand y no el ajuste por defecto: sin esto el Stack se mide por el
      // hijo y la tarjeta, que se posiciona respecto a sus bordes, acaba fuera
      // de la ventana en cuanto el hijo no la llena entera.
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned(
          right: Spacing.lg,
          bottom: Spacing.lg,
          child: _SuggestionCard(
            url: url,
            onSave: () => unawaited(_save()),
            onDismiss: _dismiss,
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.url,
    required this.onSave,
    required this.onDismiss,
  });

  final String url;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(Radii.card),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.content_paste_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    l10n.clipboardSuggestionTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: onDismiss,
                  child: Text(l10n.clipboardSuggestionDismiss),
                ),
                const SizedBox(width: Spacing.sm),
                FilledButton(
                  onPressed: onSave,
                  child: Text(l10n.clipboardSuggestionSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
