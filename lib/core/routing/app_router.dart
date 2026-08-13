import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/categories_screen.dart';
import '../../features/categories/presentation/category_links_screen.dart';
import '../../features/dev/presentation/design_system_gallery.dart';
import '../../features/kanban/presentation/kanban_screen.dart';
import '../../features/links/presentation/link_list_filters.dart';
import '../../features/links/presentation/links_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/sharing/presentation/share_spike_screen.dart';
import '../../shared/layout/adaptive_shell.dart';
import '../l10n/app_localizations.dart';
import 'routes.dart';

GoRouter createAppRouter({
  required String initialLocation,
  required ValueChanged<Brightness> onToggleTheme,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    // Escritorio puede conservar una ruta inicial del ciclo anterior en el
    // motor. La fuente de verdad es siempre el bootstrap de SambaLinks.
    overridePlatformDefaultLocation: true,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AdaptiveShell(
              navigationShell: navigationShell,
              onToggleTheme: () => onToggleTheme(Theme.of(context).brightness),
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const LinksListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'inbox',
                    builder: (BuildContext context, GoRouterState state) {
                      final L10n l10n = L10n.of(context);
                      return LinksListScreen(
                        initialFilters: const LinkListFilters(
                          uncategorized: true,
                        ),
                        scopeTitle: l10n.inbox,
                        scopeSubtitle: l10n.inboxDescription,
                        scopeCloseRoute: AppRoutes.home,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.kanban,
                builder: (BuildContext context, GoRouterState state) =>
                    const KanbanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.categories,
                builder: (BuildContext context, GoRouterState state) =>
                    const CategoriesScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':categoryId',
                    builder: (BuildContext context, GoRouterState state) =>
                        CategoryLinksScreen(
                          categoryId: state.pathParameters['categoryId']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (BuildContext context, GoRouterState state) =>
            DesignSystemGallery(
              onToggleTheme: () => onToggleTheme(Theme.of(context).brightness),
            ),
      ),
      GoRoute(
        path: AppRoutes.shareSpike,
        builder: (BuildContext context, GoRouterState state) =>
            ShareSpikeScreen(
              onToggleTheme: () => onToggleTheme(Theme.of(context).brightness),
            ),
      ),
    ],
  );
}
