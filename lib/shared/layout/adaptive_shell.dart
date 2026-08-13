import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/tokens.dart';
import '../../features/categories/domain/category.dart';
import '../../features/links/domain/enums.dart';
import '../../features/links/presentation/add_link_sheet.dart';
import '../../features/links/presentation/link_detail_pane.dart';
import 'breakpoints.dart';

class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({
    required this.navigationShell,
    required this.onToggleTheme,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onToggleTheme;

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  bool _sidebarExpanded = true;

  void _select(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(seedProvider);
    ref.watch(orphanImageCleanupProvider);

    final L10n l10n = L10n.of(context);
    final SambaWindowClass windowClass = SambaBreakpoints.fromWidth(
      MediaQuery.sizeOf(context).width,
    );
    final Map<CardStatus, int> statuses =
        ref.watch(statusCountsProvider).asData?.value ??
        const <CardStatus, int>{};
    final int totalLinks = statuses.values.fold(0, (int a, int b) => a + b);
    final int inboxCount = ref.watch(inboxCountProvider).asData?.value ?? 0;
    final List<CategorySummary> categorySummaries =
        ref.watch(categorySummariesProvider).asData?.value ??
        const <CategorySummary>[];
    final _NavigationCounts counts = _NavigationCounts(
      totalLinks: totalLinks,
      categoryCount: categorySummaries.length,
      inboxCount: inboxCount,
    );

    return switch (windowClass) {
      SambaWindowClass.mobile => _buildMobile(context, l10n, counts),
      SambaWindowClass.tablet => _buildTablet(context, l10n, counts),
      SambaWindowClass.desktop => _buildDesktop(
        context,
        l10n,
        counts,
        categorySummaries,
        showDetailPane: false,
      ),
      SambaWindowClass.wideDesktop => _buildDesktop(
        context,
        l10n,
        counts,
        categorySummaries,
        showDetailPane: true,
      ),
    };
  }

  Widget _buildMobile(
    BuildContext context,
    L10n l10n,
    _NavigationCounts counts,
  ) {
    return Scaffold(
      key: const ValueKey<String>('mobile-shell'),
      appBar: _ShellAppBar(
        title: _label(l10n, widget.navigationShell.currentIndex),
        onToggleTheme: widget.onToggleTheme,
      ),
      body: widget.navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => unawaited(AddLinkSheet.show(context)),
        tooltip: l10n.addLinkTitle,
        child: const Icon(Icons.add_link),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: _destinations(l10n, counts),
      ),
    );
  }

  Widget _buildTablet(
    BuildContext context,
    L10n l10n,
    _NavigationCounts counts,
  ) {
    return Scaffold(
      key: const ValueKey<String>('tablet-shell'),
      appBar: _ShellAppBar(
        title: _label(l10n, widget.navigationShell.currentIndex),
        onToggleTheme: widget.onToggleTheme,
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _select,
            labelType: NavigationRailLabelType.all,
            destinations: _railDestinations(l10n, counts),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    L10n l10n,
    _NavigationCounts counts,
    List<CategorySummary> categorySummaries, {
    required bool showDetailPane,
  }) {
    return Scaffold(
      key: ValueKey<String>(
        showDetailPane ? 'wide-desktop-shell' : 'desktop-shell',
      ),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            _DesktopSidebar(
              expanded: _sidebarExpanded,
              selectedIndex: widget.navigationShell.currentIndex,
              counts: counts,
              categories: categorySummaries,
              onSelect: _select,
              onToggleExpanded: () =>
                  setState(() => _sidebarExpanded = !_sidebarExpanded),
              onToggleTheme: widget.onToggleTheme,
              onOpenInbox: () => context.go(AppRoutes.inbox),
              onOpenCategory: (String id) =>
                  context.go(AppRoutes.category(id)),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: <Widget>[
                  _DesktopTopBar(
                    title: _label(l10n, widget.navigationShell.currentIndex),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
            if (showDetailPane) ...<Widget>[
              const VerticalDivider(width: 1),
              const SizedBox(width: 360, child: LinkDetailHost()),
            ],
          ],
        ),
      ),
    );
  }

  List<NavigationDestination> _destinations(
    L10n l10n,
    _NavigationCounts counts,
  ) {
    return <NavigationDestination>[
      NavigationDestination(
        icon: _NavigationIcon(
          icon: Icons.home_outlined,
          count: counts.totalLinks,
        ),
        selectedIcon: _NavigationIcon(
          icon: Icons.home,
          count: counts.totalLinks,
        ),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: _NavigationIcon(
          icon: Icons.view_kanban_outlined,
          count: counts.totalLinks,
        ),
        selectedIcon: _NavigationIcon(
          icon: Icons.view_kanban,
          count: counts.totalLinks,
        ),
        label: l10n.navKanban,
      ),
      NavigationDestination(
        icon: _NavigationIcon(
          icon: Icons.folder_outlined,
          count: counts.categoryCount,
        ),
        selectedIcon: _NavigationIcon(
          icon: Icons.folder,
          count: counts.categoryCount,
        ),
        label: l10n.navCategories,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.navSettings,
      ),
    ];
  }

  List<NavigationRailDestination> _railDestinations(
    L10n l10n,
    _NavigationCounts counts,
  ) {
    final List<NavigationDestination> destinations = _destinations(
      l10n,
      counts,
    );
    return <NavigationRailDestination>[
      for (final NavigationDestination destination in destinations)
        NavigationRailDestination(
          icon: destination.icon,
          selectedIcon: destination.selectedIcon,
          label: Text(destination.label),
        ),
    ];
  }

  String _label(L10n l10n, int index) => switch (index) {
    1 => l10n.navKanban,
    2 => l10n.navCategories,
    3 => l10n.navSettings,
    _ => l10n.navHome,
  };
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShellAppBar({required this.title, required this.onToggleTheme});

  final String title;
  final VoidCallback onToggleTheme;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      title: Row(
        children: <Widget>[
          Image.asset('assets/brand/logo.png', width: 28, height: 28),
          const SizedBox(width: Spacing.md),
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: <Widget>[
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDark ? l10n.themeLight : l10n.themeDark,
        ),
      ],
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.expanded,
    required this.selectedIndex,
    required this.counts,
    required this.categories,
    required this.onSelect,
    required this.onToggleExpanded,
    required this.onToggleTheme,
    required this.onOpenInbox,
    required this.onOpenCategory,
  });

  final bool expanded;
  final int selectedIndex;
  final _NavigationCounts counts;
  final List<CategorySummary> categories;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenInbox;
  final ValueChanged<String> onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final List<_SidebarItemData> items = <_SidebarItemData>[
      _SidebarItemData(Icons.home_outlined, l10n.navHome, counts.totalLinks),
      _SidebarItemData(
        Icons.view_kanban_outlined,
        l10n.navKanban,
        counts.totalLinks,
      ),
      _SidebarItemData(
        Icons.folder_outlined,
        l10n.navCategories,
        counts.categoryCount,
      ),
      _SidebarItemData(Icons.settings_outlined, l10n.navSettings, null),
    ];

    return AnimatedContainer(
      key: const ValueKey<String>('desktop-sidebar'),
      duration: disableAnimations ? Duration.zero : MotionDurations.panel,
      curve: MotionCurves.standard,
      width: expanded ? 264 : 80,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: Spacing.lg),
                Image.asset('assets/brand/logo.png', width: 32, height: 32),
                if (expanded) ...<Widget>[
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Text(
                      l10n.appName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const SizedBox(width: Spacing.lg),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              children: <Widget>[
                for (int index = 0; index < items.length; index++)
                  _SidebarDestination(
                    data: items[index],
                    expanded: expanded,
                    selected: selectedIndex == index,
                    onTap: () => onSelect(index),
                  ),
                const Divider(height: Spacing.xxl),
                _SidebarDestination(
                  data: _SidebarItemData(
                    Icons.inbox_outlined,
                    l10n.inbox,
                    counts.inboxCount,
                  ),
                  expanded: expanded,
                  selected: false,
                  onTap: onOpenInbox,
                ),
                if (expanded)
                  for (final CategorySummary summary in categories)
                    _CategoryCounter(
                      summary: summary,
                      onTap: () => onOpenCategory(summary.category.id),
                    ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: expanded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _ThemeButton(onPressed: onToggleTheme),
                      IconButton(
                        key: const ValueKey<String>('collapse-sidebar'),
                        onPressed: onToggleExpanded,
                        icon: const Icon(Icons.keyboard_double_arrow_left),
                        tooltip: l10n.navigationCollapse,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _ThemeButton(onPressed: onToggleTheme),
                      IconButton(
                        key: const ValueKey<String>('expand-sidebar'),
                        onPressed: onToggleExpanded,
                        icon: const Icon(Icons.keyboard_double_arrow_right),
                        tooltip: l10n.navigationExpand,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.data,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  final _SidebarItemData data;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    final String semanticLabel = data.count == null
        ? data.label
        : l10n.navigationDestinationCount(data.label, data.count!);
    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xs),
        child: Material(
          color: selected
              ? samba.surfaceElevated
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(Radii.chip),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Radii.chip),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TouchTargets.minimum,
              ),
              child: expanded
                  ? Row(
                      children: <Widget>[
                        const SizedBox(width: Spacing.md),
                        Icon(data.icon),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Text(
                            data.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.count != null)
                          _CounterBadge(count: data.count!),
                        const SizedBox(width: Spacing.md),
                      ],
                    )
                  : Center(
                      child: data.count == null
                          ? Icon(data.icon)
                          : Badge.count(
                              count: data.count!,
                              child: Icon(data.icon),
                            ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? l10n.themeLight : l10n.themeDark,
    );
  }
}

class _CategoryCounter extends StatelessWidget {
  const _CategoryCounter({required this.summary, required this.onTap});

  final CategorySummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        SambaPalette.tryParseHex(summary.category.color) ??
        Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.chip),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.md,
          Spacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                summary.category.name,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _CounterBadge(count: summary.linkCount),
          ],
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return count > 0
        ? Badge.count(count: count, child: Icon(icon))
        : Icon(icon);
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _NavigationCounts {
  const _NavigationCounts({
    required this.totalLinks,
    required this.categoryCount,
    required this.inboxCount,
  });

  final int totalLinks;
  final int categoryCount;
  final int inboxCount;
}

class _SidebarItemData {
  const _SidebarItemData(this.icon, this.label, this.count);

  final IconData icon;
  final String label;
  final int? count;
}
