import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/layout/breakpoints.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/link_card.dart' as ui;
import '../../categories/domain/category.dart';
import '../../links/domain/enums.dart';
import '../../links/domain/link_card.dart';
import '../../links/domain/link_query.dart';
import '../../links/presentation/link_detail_pane.dart';

/// Tablero de tres columnas: Pendiente, Activo y Atendido (§21 del PRD).
///
/// [categoryId] acota el tablero a una categoría (§22), lo que convierte
/// SambaLinks en una herramienta de investigación por proyecto.
class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({this.categoryId, this.scopeTitle, super.key});

  final String? categoryId;
  final String? scopeTitle;

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  final ScrollController _boardController = ScrollController();
  Timer? _edgeScrollTimer;

  /// Estado que se está arrastrando ahora mismo, para atenuar su columna de
  /// origen y resaltar los destinos válidos.
  CardStatus? _draggingFrom;

  @override
  void dispose() {
    _edgeScrollTimer?.cancel();
    _boardController.dispose();
    super.dispose();
  }

  CardFilter _filterFor(CardStatus status) {
    return CardFilter(
      statuses: <CardStatus>{status},
      categoryIds: widget.categoryId == null
          ? null
          : <String>{widget.categoryId!},
    );
  }

  Future<void> _move(LinkCard card, CardStatus target) async {
    if (card.status == target) {
      return;
    }
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CardStatus previous = card.status;

    await ref.read(linkRepositoryProvider).updateStatus(card.id, target);
    if (!mounted) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.kanbanMoved(_statusLabel(l10n, target))),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => unawaited(
              ref.read(linkRepositoryProvider).updateStatus(card.id, previous),
            ),
          ),
        ),
      );
  }

  /// Desplaza el tablero cuando se arrastra cerca de un borde: sin esto no se
  /// puede soltar en una columna que está fuera de la pantalla, que en móvil
  /// es siempre el caso.
  void _handleDragUpdate(DragTargetDetails<LinkCard>? _, Offset globalPosition) {
    if (!_boardController.hasClients) {
      return;
    }
    const double edge = 72;
    final double width = MediaQuery.sizeOf(context).width;
    final double dx = globalPosition.dx;

    final double? direction = dx < edge
        ? -1
        : (dx > width - edge ? 1 : null);

    if (direction == null) {
      _edgeScrollTimer?.cancel();
      _edgeScrollTimer = null;
      return;
    }
    _edgeScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_boardController.hasClients) {
        return;
      }
      final double next = (_boardController.offset + direction * 12).clamp(
        0,
        _boardController.position.maxScrollExtent,
      );
      _boardController.jumpTo(next);
    });
  }

  void _stopEdgeScroll() {
    _edgeScrollTimer?.cancel();
    _edgeScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final Map<CardStatus, int> counts =
        ref
            .watch(
              scopedStatusCountsProvider(
                LinkQuery(
                  filter: CardFilter(
                    categoryIds: widget.categoryId == null
                        ? null
                        : <String>{widget.categoryId!},
                  ),
                ),
              ),
            )
            .asData
            ?.value ??
        const <CardStatus, int>{};

    final int total = counts.values.fold(0, (int a, int b) => a + b);
    if (total == 0) {
      return EmptyState(
        icon: Icons.view_kanban_outlined,
        title: l10n.kanbanEmptyTitle,
        body: l10n.kanbanEmptyBody,
      );
    }

    // En móvil las columnas ocupan casi toda la pantalla y se deslizan en
    // horizontal; en escritorio caben varias a la vez.
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide =
        SambaBreakpoints.fromWidth(width) != SambaWindowClass.mobile;
    final double columnWidth = wide ? 340 : width * 0.82;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.scopeTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.lg,
              Spacing.lg,
              0,
            ),
            child: Text(
              widget.scopeTitle!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        Expanded(
          child: ListView(
            controller: _boardController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              for (final CardStatus status in CardStatus.values) ...<Widget>[
                SizedBox(
                  width: columnWidth,
                  child: _KanbanColumn(
                    status: status,
                    count: counts[status] ?? 0,
                    filter: _filterFor(status),
                    draggingFrom: _draggingFrom,
                    onDragStarted: (CardStatus from) =>
                        setState(() => _draggingFrom = from),
                    onDragEnded: () {
                      _stopEdgeScroll();
                      setState(() => _draggingFrom = null);
                    },
                    onDragUpdate: _handleDragUpdate,
                    onAccept: _move,
                    onMoveRequested: _move,
                  ),
                ),
                const SizedBox(width: Spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  const _KanbanColumn({
    required this.status,
    required this.count,
    required this.filter,
    required this.draggingFrom,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDragUpdate,
    required this.onAccept,
    required this.onMoveRequested,
  });

  final CardStatus status;
  final int count;
  final CardFilter filter;
  final CardStatus? draggingFrom;
  final ValueChanged<CardStatus> onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(DragTargetDetails<LinkCard>?, Offset) onDragUpdate;
  final Future<void> Function(LinkCard, CardStatus) onAccept;
  final Future<void> Function(LinkCard, CardStatus) onMoveRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;
    final AsyncValue<List<LinkCard>> cards = ref.watch(
      linksProvider(LinkQuery(filter: filter)),
    );

    final bool isDropTarget = draggingFrom != null && draggingFrom != status;

    return DragTarget<LinkCard>(
      onWillAcceptWithDetails: (DragTargetDetails<LinkCard> details) =>
          details.data.status != status,
      onAcceptWithDetails: (DragTargetDetails<LinkCard> details) =>
          unawaited(onAccept(details.data, status)),
      onMove: (DragTargetDetails<LinkCard> details) =>
          onDragUpdate(details, details.offset),
      builder:
          (
            BuildContext context,
            List<LinkCard?> candidates,
            List<dynamic> rejected,
          ) {
            final bool hovering = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: hovering
                    ? _statusBackground(samba, status)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(
                  color: hovering
                      ? _statusForeground(samba, status)
                      : theme.colorScheme.outline,
                  width: hovering ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ColumnHeader(status: status, count: count),
                  const SizedBox(height: Spacing.md),
                  Expanded(
                    child: cards.when(
                      data: (List<LinkCard> items) {
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              isDropTarget
                                  ? l10n.kanbanDropHere
                                  : l10n.kanbanColumnEmpty,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: Spacing.sm),
                          itemBuilder: (BuildContext context, int index) =>
                              _KanbanCard(
                                card: items[index],
                                onDragStarted: () => onDragStarted(status),
                                onDragEnded: onDragEnded,
                                onMoveRequested: onMoveRequested,
                              ),
                        );
                      },
                      loading: () => const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (Object error, StackTrace _) => Center(
                        child: Text(
                          l10n.kanbanLoadError,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.status, required this.count});

  final CardStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;

    return Row(
      children: <Widget>[
        Icon(Icons.circle, size: 10, color: _statusForeground(samba, status)),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            _statusLabel(l10n, status),
            style: theme.textTheme.titleMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _statusBackground(samba, status),
            borderRadius: BorderRadius.circular(Radii.chip),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: _statusForeground(samba, status),
            ),
          ),
        ),
      ],
    );
  }
}

class _KanbanCard extends ConsumerWidget {
  const _KanbanCard({
    required this.card,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onMoveRequested,
  });

  final LinkCard card;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Future<void> Function(LinkCard, CardStatus) onMoveRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories =
        ref.watch(categoriesOfProvider(card.id)).asData?.value ??
        const <Category>[];

    final Widget content = ui.LinkCard(
      card: card,
      categories: categories,
      density: ui.LinkCardDensity.compact,
      showStatus: false,
      onTap: () => unawaited(LinkDetailPane.show(context, card)),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: LongPressDraggable<LinkCard>(
            data: card,
            onDragStarted: onDragStarted,
            onDragEnd: (_) => onDragEnded(),
            onDraggableCanceled: (_, _) => onDragEnded(),
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.9,
                child: SizedBox(width: 300, child: content),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: content),
            child: content,
          ),
        ),
        // Alternativa accesible al arrastre. Arrastrar con el dedo es incómodo
        // y queda fuera del alcance de un lector de pantalla, así que cambiar
        // de estado tiene que ser posible sin gesto.
        _MoveMenu(card: card, onMoveRequested: onMoveRequested),
      ],
    );
  }
}

class _MoveMenu extends StatelessWidget {
  const _MoveMenu({required this.card, required this.onMoveRequested});

  final LinkCard card;
  final Future<void> Function(LinkCard, CardStatus) onMoveRequested;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);

    return PopupMenuButton<CardStatus>(
      icon: const Icon(Icons.swap_horiz),
      tooltip: l10n.kanbanMoveAction(card.displayTitle),
      onSelected: (CardStatus status) =>
          unawaited(onMoveRequested(card, status)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<CardStatus>>[
        for (final CardStatus status in CardStatus.values)
          if (status != card.status)
            PopupMenuItem<CardStatus>(
              value: status,
              child: Text(l10n.kanbanMoveTo(_statusLabel(l10n, status))),
            ),
      ],
    );
  }
}

String _statusLabel(L10n l10n, CardStatus status) => switch (status) {
  CardStatus.pending => l10n.statusPending,
  CardStatus.active => l10n.statusActive,
  CardStatus.done => l10n.statusDone,
};

Color _statusForeground(SambaColors samba, CardStatus status) =>
    switch (status) {
      CardStatus.pending => samba.pendingFg,
      CardStatus.active => samba.activeFg,
      CardStatus.done => samba.doneFg,
    };

Color _statusBackground(SambaColors samba, CardStatus status) =>
    switch (status) {
      CardStatus.pending => samba.pendingBg,
      CardStatus.active => samba.activeBg,
      CardStatus.done => samba.doneBg,
    };
