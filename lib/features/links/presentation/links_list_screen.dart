import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/link_card.dart' as ui;
import '../../../shared/widgets/samba_button.dart';
import '../../../shared/widgets/samba_text_field.dart';
import '../../categories/domain/category.dart';
import '../../sharing/domain/incoming_share.dart';
import '../../sharing/presentation/incoming_shares_provider.dart';
import '../domain/enums.dart';
import '../domain/link_card.dart';
import '../domain/link_query.dart';
import 'add_link_sheet.dart';
import 'link_detail_pane.dart';
import 'link_filters_sheet.dart';
import 'link_list_filters.dart';
import 'link_selection_provider.dart';

class LinksListScreen extends ConsumerStatefulWidget {
  const LinksListScreen({
    this.initialFilters = LinkListFilters.empty,
    this.scopeTitle,
    this.scopeSubtitle,
    this.scopeCloseRoute,
    super.key,
  });

  final LinkListFilters initialFilters;
  final String? scopeTitle;
  final String? scopeSubtitle;
  final String? scopeCloseRoute;

  @override
  ConsumerState<LinksListScreen> createState() => _LinksListScreenState();
}

class _LinksListScreenState extends ConsumerState<LinksListScreen> {
  static const int _pageSize = 40;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _query = '';
  late LinkListFilters _filters;
  int _loadedPages = 1;
  bool _compact = false;
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _query = value.trim();
        _loadedPages = 1;
        _selectedIds.clear();
      });
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _loadedPages = 1;
    });
  }

  void _setFilters(LinkListFilters value) {
    setState(() {
      _filters = value;
      _loadedPages = 1;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CardSort sort =
        ref.watch(cardSortPreferenceProvider).asData?.value ?? CardSort.newest;
    final CardFilter effectiveFilter = _filters.toCardFilter(query: _query);
    final LinkQuery countQuery = LinkQuery(filter: effectiveFilter);
    final int? total = ref.watch(linkCountProvider(countQuery)).asData?.value;
    // Los contadores de las pestañas se acotan al ámbito visible pero ignoran
    // el filtro de estado: dentro de la Bandeja deben sumar los de la Bandeja,
    // y seleccionar "Pendiente" no puede poner las demás pestañas a cero.
    final LinkQuery statusCountQuery = LinkQuery(
      filter: _filters
          .withStatuses(const <CardStatus>{})
          .toCardFilter(query: _query),
    );
    final Map<CardStatus, int> statusCounts =
        ref.watch(scopedStatusCountsProvider(statusCountQuery)).asData?.value ??
        const <CardStatus, int>{};
    final List<Category> categories =
        ref.watch(categoriesProvider).asData?.value ?? const <Category>[];
    final List<IncomingShare> incoming = ref.watch(incomingSharesProvider);

    final List<AsyncValue<List<LinkCard>>> pages = <AsyncValue<List<LinkCard>>>[
      for (int page = 0; page < _loadedPages; page++)
        ref.watch(
          linksProvider(
            LinkQuery(
              filter: effectiveFilter,
              sort: sort,
              limit: _pageSize,
              offset: page * _pageSize,
            ),
          ),
        ),
    ];
    final Object? error = pages
        .where((AsyncValue<List<LinkCard>> value) => value.hasError)
        .firstOrNull
        ?.error;
    final bool loading = pages.any(
      (AsyncValue<List<LinkCard>> value) => value.isLoading,
    );
    final List<LinkCard> cards = _mergePages(pages);
    final bool hasMore =
        pages.lastOrNull?.asData?.value.length == _pageSize &&
        (total == null || cards.length < total);

    return Column(
      children: <Widget>[
        if (widget.scopeTitle != null)
          _ListScopeHeader(
            title: widget.scopeTitle!,
            subtitle: widget.scopeSubtitle,
            onClose: widget.scopeCloseRoute == null
                ? null
                : () => context.go(widget.scopeCloseRoute!),
          ),
        _ListToolbar(
          controller: _searchController,
          query: _query,
          filters: _filters,
          sort: sort,
          compact: _compact,
          statusCounts: statusCounts,
          inboxCount: ref.watch(inboxCountProvider).asData?.value ?? 0,
          // En la propia Bandeja el acceso desaparece.
          onOpenInbox: widget.initialFilters.uncategorized
              ? null
              : () => context.go(AppRoutes.inbox),
          onSearchChanged: _search,
          onClearSearch: _clearSearch,
          onStatusChanged: (Set<CardStatus> statuses) =>
              _setFilters(_filters.withStatuses(statuses)),
          onShowFilters: () async {
            final LinkListFilters? value = await LinkFiltersSheet.show(
              context: context,
              initial: _filters,
              options: LinkFilterOptions(categories: categories),
            );
            if (value != null && mounted) {
              _setFilters(value);
            }
          },
          onClearFilters: () => _setFilters(LinkListFilters.empty),
          onSortChanged: (CardSort value) =>
              ref.read(cardSortPreferenceProvider.notifier).setSort(value),
          onToggleCompact: () => setState(() => _compact = !_compact),
        ),
        if (_selectedIds.isNotEmpty)
          _SelectionToolbar(
            count: _selectedIds.length,
            onClear: () => setState(_selectedIds.clear),
          ),
        if (incoming.isNotEmpty)
          _IncomingShareBanner(
            share: incoming.first,
            onDismiss: () => ref
                .read(incomingSharesProvider.notifier)
                .dismiss(incoming.first),
          ),
        Expanded(
          child: _buildBody(
            context: context,
            cards: cards,
            loading: loading,
            error: error,
            hasMore: hasMore,
            total: total,
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required List<LinkCard> cards,
    required bool loading,
    required Object? error,
    required bool hasMore,
    required int? total,
  }) {
    final L10n l10n = L10n.of(context);
    if (error != null && cards.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l10n.linksLoadErrorTitle,
        body: l10n.linksLoadErrorBody,
        actionLabel: l10n.tryAgain,
        onAction: () => ref.invalidate(linksProvider),
      );
    }
    if (loading && cards.isEmpty) {
      return Center(
        child: Semantics(
          label: l10n.loadingLinks,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (cards.isEmpty) {
      if (_query.isNotEmpty) {
        return EmptyState(
          icon: Icons.search_off,
          title: l10n.searchEmptyTitle(_query),
          body: l10n.searchEmptyBody,
          actionLabel: l10n.clearFilters,
          onAction: () {
            _clearSearch();
            _setFilters(LinkListFilters.empty);
          },
        );
      }
      if (!_filters.isEmpty) {
        if (_filters.uncategorized) {
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.inboxEmptyTitle,
            body: l10n.inboxEmptyBody,
            actionLabel: l10n.addFirstLink,
            onAction: () => unawaited(AddLinkSheet.show(context)),
          );
        }
        return EmptyState(
          icon: Icons.filter_alt_off_outlined,
          title: l10n.filterEmptyTitle,
          body: l10n.filterEmptyBody,
          actionLabel: l10n.clearFilters,
          onAction: () => _setFilters(LinkListFilters.empty),
        );
      }
      return EmptyState(
        icon: Icons.bookmarks_outlined,
        title: l10n.libraryEmptyTitle,
        body: l10n.libraryEmptyBody,
        actionLabel: l10n.addFirstLink,
        onAction: () => unawaited(AddLinkSheet.show(context)),
      );
    }

    final ui.LinkCardDensity density = _densityFor(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (hasMore && !loading && notification.metrics.extentAfter < 400) {
          setState(() => _loadedPages++);
        }
        return false;
      },
      child: ListView.separated(
        key: const PageStorageKey<String>('links-list'),
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.xxl,
        ),
        itemCount: cards.length + 2,
        separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Text(
              l10n.resultCount(total ?? cards.length),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }
          if (index == cards.length + 1) {
            if (loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.lg),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!hasMore) {
              return const SizedBox.shrink();
            }
            return Center(
              child: SambaButton(
                label: l10n.loadMore,
                variant: SambaButtonVariant.secondary,
                onPressed: () => setState(() => _loadedPages++),
              ),
            );
          }
          final LinkCard card = cards[index - 1];
          return _LinkCardItem(
            card: card,
            density: density,
            selected: _selectedIds.contains(card.id),
            selectionMode: _selectedIds.isNotEmpty,
            onTap: () {
              if (_selectedIds.isNotEmpty) {
                _toggleSelection(card.id);
              } else {
                _openDetail(card);
              }
            },
            onLongPress: () => _toggleSelection(card.id),
            onSelectionChanged: (_) => _toggleSelection(card.id),
          );
        },
      ),
    );
  }

  ui.LinkCardDensity _densityFor(BuildContext context) {
    if (_compact) {
      return ui.LinkCardDensity.compact;
    }
    return MediaQuery.sizeOf(context).width < 600
        ? ui.LinkCardDensity.mobile
        : ui.LinkCardDensity.desktop;
  }

  void _toggleSelection(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
    });
  }

  void _openDetail(LinkCard card) {
    ref.read(selectedLinkProvider.notifier).select(card);
    if (MediaQuery.sizeOf(context).width <= 1400) {
      unawaited(LinkDetailPane.show(context, card));
    }
  }

  List<LinkCard> _mergePages(List<AsyncValue<List<LinkCard>>> pages) {
    final Map<String, LinkCard> unique = <String, LinkCard>{};
    for (final AsyncValue<List<LinkCard>> page in pages) {
      for (final LinkCard card in page.asData?.value ?? const <LinkCard>[]) {
        unique[card.id] = card;
      }
    }
    return unique.values.toList(growable: false);
  }
}

class _ListScopeHeader extends StatelessWidget {
  const _ListScopeHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.md,
          Spacing.sm,
          Spacing.xs,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                tooltip: l10n.scopeClose,
              ),
          ],
        ),
      ),
    );
  }
}

class _LinkCardItem extends ConsumerWidget {
  const _LinkCardItem({
    required this.card,
    required this.density,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  });

  final LinkCard card;
  final ui.LinkCardDensity density;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? storedImage = card.localImage;
    String? resolvedImage;
    if (storedImage != null && storedImage.isNotEmpty) {
      if (storedImage.startsWith('/')) {
        resolvedImage = storedImage;
      } else {
        final String? root = ref
            .watch(applicationSupportDirectoryProvider)
            .asData
            ?.value
            .path;
        if (root != null) {
          resolvedImage = '$root/$storedImage';
        }
      }
    }
    final LinkCard displayCard = resolvedImage == null
        ? card
        : card.copyWith(localImage: resolvedImage);
    final List<Category> categories =
        ref.watch(categoriesOfProvider(card.id)).asData?.value ??
        const <Category>[];
    return ui.LinkCard(
      card: displayCard,
      categories: categories,
      density: density,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      onSelectionChanged: selectionMode ? onSelectionChanged : null,
    );
  }
}

class _ListToolbar extends StatelessWidget {
  const _ListToolbar({
    required this.controller,
    required this.query,
    required this.filters,
    required this.sort,
    required this.compact,
    required this.statusCounts,
    required this.inboxCount,
    required this.onOpenInbox,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStatusChanged,
    required this.onShowFilters,
    required this.onClearFilters,
    required this.onSortChanged,
    required this.onToggleCompact,
  });

  final TextEditingController controller;
  final String query;
  final LinkListFilters filters;
  final CardSort sort;
  final bool compact;
  final Map<CardStatus, int> statusCounts;
  final int inboxCount;

  /// `null` cuando la lista ya está acotada a la Bandeja: no tiene sentido
  /// ofrecer entrar donde ya estás.
  final VoidCallback? onOpenInbox;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<Set<CardStatus>> onStatusChanged;
  final VoidCallback onShowFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<CardSort> onSortChanged;
  final VoidCallback onToggleCompact;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget search = SambaTextField(
                  controller: controller,
                  hint: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close),
                          tooltip: l10n.clearFilters,
                        ),
                  textInputAction: TextInputAction.search,
                  onChanged: onSearchChanged,
                );
                final Widget actions = _ToolbarActions(
                  filters: filters,
                  sort: sort,
                  compact: compact,
                  onShowFilters: onShowFilters,
                  onClearFilters: onClearFilters,
                  onSortChanged: onSortChanged,
                  onToggleCompact: onToggleCompact,
                );
                if (constraints.maxWidth < 720) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      search,
                      const SizedBox(height: Spacing.sm),
                      actions,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: search),
                    const SizedBox(width: Spacing.md),
                    SizedBox(width: 360, child: actions),
                  ],
                );
              },
            ),
            const SizedBox(height: Spacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _StatusChoice(
                    label: l10n.allLinks,
                    count: statusCounts.values.fold(
                      0,
                      (int total, int value) => total + value,
                    ),
                    selected: filters.statuses.isEmpty,
                    onSelected: () => onStatusChanged(const <CardStatus>{}),
                  ),
                  for (final CardStatus status
                      in CardStatus.values) ...<Widget>[
                    const SizedBox(width: Spacing.sm),
                    _StatusChoice(
                      label: _statusLabel(l10n, status),
                      count: statusCounts[status] ?? 0,
                      selected:
                          filters.statuses.length == 1 &&
                          filters.statuses.contains(status),
                      onSelected: () => onStatusChanged(<CardStatus>{status}),
                    ),
                  ],
                  // La Bandeja es el centro del flujo del PRD (§16): todo lo
                  // compartido cae ahí sin categoría. Hasta ahora sólo se
                  // alcanzaba desde la barra lateral de escritorio, así que en
                  // móvil —la plataforma prioritaria— era invisible.
                  if (onOpenInbox != null) ...<Widget>[
                    const SizedBox(width: Spacing.sm),
                    _StatusChoice(
                      label: l10n.inbox,
                      count: inboxCount,
                      selected: false,
                      onSelected: onOpenInbox!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarActions extends StatelessWidget {
  const _ToolbarActions({
    required this.filters,
    required this.sort,
    required this.compact,
    required this.onShowFilters,
    required this.onClearFilters,
    required this.onSortChanged,
    required this.onToggleCompact,
  });

  final LinkListFilters filters;
  final CardSort sort;
  final bool compact;
  final VoidCallback onShowFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<CardSort> onSortChanged;
  final VoidCallback onToggleCompact;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShowFilters,
            icon: filters.activeCount == 0
                ? const Icon(Icons.filter_alt_outlined)
                : Badge.count(
                    count: filters.activeCount,
                    child: const Icon(Icons.filter_alt),
                  ),
            label: Text(
              filters.activeCount == 0
                  ? l10n.filters
                  : l10n.filterActiveCount(filters.activeCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        PopupMenuButton<CardSort>(
          initialValue: sort,
          tooltip: l10n.sortMenuTooltip,
          icon: const Icon(Icons.swap_vert),
          onSelected: onSortChanged,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<CardSort>>[
            for (final CardSort value in CardSort.values)
              CheckedPopupMenuItem<CardSort>(
                value: value,
                checked: value == sort,
                child: Text(_sortLabel(l10n, value)),
              ),
          ],
        ),
        IconButton(
          onPressed: onToggleCompact,
          icon: Icon(compact ? Icons.view_agenda_outlined : Icons.view_list),
          tooltip: compact ? l10n.viewComfortable : l10n.viewCompact,
        ),
      ],
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('$label · $count'),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({required this.count, required this.onClear});

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    return ColoredBox(
      color: samba.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(l10n.selectedLinksCount(count))),
            TextButton(onPressed: onClear, child: Text(l10n.clearSelection)),
          ],
        ),
      ),
    );
  }
}

class _IncomingShareBanner extends StatelessWidget {
  const _IncomingShareBanner({required this.share, required this.onDismiss});

  final IncomingShare share;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    return ColoredBox(
      color: samba.activeBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.link, color: samba.activeFg),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.incomingLinkReceived,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: samba.activeFg),
                  ),
                  Text(
                    share.normalized?.canonical ?? share.url ?? share.rawText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              tooltip: l10n.dismiss,
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(L10n l10n, CardStatus status) => switch (status) {
  CardStatus.pending => l10n.statusPending,
  CardStatus.active => l10n.statusActive,
  CardStatus.done => l10n.statusDone,
};

String _sortLabel(L10n l10n, CardSort sort) => switch (sort) {
  CardSort.newest => l10n.sortNewest,
  CardSort.oldest => l10n.sortOldest,
  CardSort.recentlyUpdated => l10n.sortRecentlyUpdated,
  CardSort.titleAsc => l10n.sortTitleAsc,
  CardSort.titleDesc => l10n.sortTitleDesc,
  CardSort.platform => l10n.sortPlatform,
  CardSort.status => l10n.sortStatus,
};
