import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../data/share_receiver.dart';
import '../domain/incoming_share.dart';

/// Pantalla del spike de la Fase 1A.
///
/// No es UI de producto: su único trabajo es demostrar que un enlace
/// compartido desde otra aplicación llega hasta aquí, en frío y en caliente.
/// Se sustituye por Quick Save en la Fase 12.
class ShareSpikeScreen extends StatefulWidget {
  const ShareSpikeScreen({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  State<ShareSpikeScreen> createState() => _ShareSpikeScreenState();
}

class _ShareSpikeScreenState extends State<ShareSpikeScreen> {
  final ShareReceiver _receiver = ShareReceiver();
  final List<IncomingShare> _shares = <IncomingShare>[];
  StreamSubscription<List<IncomingShare>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _receiver.shareStream().listen(_add);
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    final List<IncomingShare> initial = await _receiver.initialShares();
    if (mounted) {
      _add(initial);
    }
  }

  void _add(List<IncomingShare> incoming) {
    if (incoming.isEmpty) {
      return;
    }
    setState(() => _shares.insertAll(0, incoming));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset('assets/brand/logo.png', width: 28, height: 28),
            const SizedBox(width: Spacing.md),
            Text(l10n.appName),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? l10n.themeLight : l10n.themeDark,
          ),
        ],
      ),
      body: _shares.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: _shares.length,
              separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
              itemBuilder: (BuildContext context, int index) =>
                  _ShareTile(share: _shares[index]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/brand/logo.png', width: 96, height: 96),
            const SizedBox(height: Spacing.xl),
            Text(
              l10n.inboxEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.inboxEmptyBody,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xxl),
            const _StatusLegend(),
          ],
        ),
      ),
    );
  }
}

/// Muestra los tres estados con sus colores para poder revisar la paleta en
/// ambos temas. Provisional: desaparece cuando llegue el design system (F6).
class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      alignment: WrapAlignment.center,
      children: <Widget>[
        _StatusChip(
          label: l10n.statusPending,
          fg: samba.pendingFg,
          bg: samba.pendingBg,
        ),
        _StatusChip(
          label: l10n.statusActive,
          fg: samba.activeFg,
          bg: samba.activeBg,
        ),
        _StatusChip(label: l10n.statusDone, fg: samba.doneFg, bg: samba.doneBg),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.circle, size: 8, color: fg),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.share});

  final IncomingShare share;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final SambaColors samba = theme.extension<SambaColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: samba.activeBg,
                    borderRadius: BorderRadius.circular(Radii.chip),
                  ),
                  child: Text(
                    share.arrival == ShareArrival.cold
                        ? 'app cerrada'
                        : 'app en segundo plano',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: samba.activeFg,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${share.receivedAt.hour.toString().padLeft(2, '0')}:'
                  '${share.receivedAt.minute.toString().padLeft(2, '0')}:'
                  '${share.receivedAt.second.toString().padLeft(2, '0')}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            SelectableText(
              share.url ?? 'Sin URL en el texto compartido',
              style: theme.textTheme.titleSmall?.copyWith(
                color: share.hasUrl ? colors.primary : samba.pendingFg,
              ),
            ),
            if (share.rawText != share.url) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Text(
                share.rawText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
