import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../categories/domain/category.dart';
import '../domain/incoming_share.dart';
import 'incoming_shares_provider.dart';

/// Pantalla del spike de la Fase 1A.
///
/// No es UI de producto: su único trabajo es demostrar que un enlace
/// compartido desde otra aplicación llega hasta aquí, en frío y en caliente.
/// Se sustituye por Quick Save en la Fase 12.
class ShareSpikeScreen extends ConsumerWidget {
  const ShareSpikeScreen({this.onToggleTheme, this.embedded = false, super.key})
    : assert(embedded || onToggleTheme != null);

  final VoidCallback? onToggleTheme;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<IncomingShare> shares = ref.watch(incomingSharesProvider);

    // Crea las categorías de ejemplo la primera vez.
    ref.watch(seedProvider);
    ref.watch(orphanImageCleanupProvider);

    final Widget body = shares.isEmpty
        ? const _EmptyState()
        : ListView.separated(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: shares.length,
            separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
            itemBuilder: (BuildContext context, int index) =>
                _ShareTile(share: shares[index]),
          );

    if (embedded) {
      return body;
    }

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
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? l10n.themeLight : l10n.themeDark,
          ),
        ],
      ),
      body: body,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableHeight = constraints.maxHeight > Spacing.xxl * 2
            ? constraints.maxHeight - Spacing.xxl * 2
            : 0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Center(
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const _StatusLegend(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Muestra los tres estados con sus colores y, debajo, las categorías leídas
/// de la base de datos.
///
/// Las categorías no son decorativas: son la prueba de que la base se crea en
/// el dispositivo, la librería nativa de SQLite está bien empaquetada y los
/// providers llegan hasta la UI. Provisional, como toda esta pantalla.
class _StatusLegend extends ConsumerWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    final AsyncValue<List<Category>> categories = ref.watch(categoriesProvider);

    return Column(
      children: <Widget>[
        Wrap(
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
            _StatusChip(
              label: l10n.statusDone,
              fg: samba.doneFg,
              bg: samba.doneBg,
            ),
          ],
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          l10n.categories.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        categories.when(
          data: (List<Category> items) => Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            alignment: WrapAlignment.center,
            children: <Widget>[
              for (final Category category in items)
                _CategoryChip(category: category),
            ],
          ),
          loading: () => const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (Object error, StackTrace _) => Text(
            '$error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        SambaPalette.tryParseHex(category.color) ?? theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        category.name,
        // Los colores de categoría son tonos claros de la paleta, así que el
        // texto va siempre en el tono más oscuro.
        style: theme.textTheme.labelLarge?.copyWith(color: SambaPalette.raven),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.fg, required this.bg});

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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
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
                        ? L10n.of(context).shareArrivalCold
                        : L10n.of(context).shareArrivalWarm,
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
              share.normalized?.canonical ??
                  share.url ??
                  L10n.of(context).shareMissingUrl,
              style: theme.textTheme.titleSmall?.copyWith(
                color: share.hasUrl ? colors.primary : samba.pendingFg,
              ),
            ),
            if (share.normalized != null) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Row(
                children: <Widget>[
                  Text(
                    share.platform.value,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '  ·  ${share.normalized!.domain}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (share.needsNetworkResolution)
                    Text(
                      '  ·  ${L10n.of(context).shortLink}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: samba.pendingFg,
                      ),
                    ),
                ],
              ),
            ],
            if (share.rawText != share.normalized?.canonical) ...<Widget>[
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
