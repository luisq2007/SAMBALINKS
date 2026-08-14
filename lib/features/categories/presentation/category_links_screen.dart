import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../kanban/presentation/kanban_screen.dart';
import '../../links/presentation/link_list_filters.dart';
import '../../links/presentation/links_list_screen.dart';
import '../domain/category.dart';

/// Cómo se están viendo los enlaces de una categoría.
enum CategoryView { list, kanban }

class CategoryLinksScreen extends ConsumerStatefulWidget {
  const CategoryLinksScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  ConsumerState<CategoryLinksScreen> createState() =>
      _CategoryLinksScreenState();
}

class _CategoryLinksScreenState extends ConsumerState<CategoryLinksScreen> {
  CategoryView _view = CategoryView.list;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String categoryId = widget.categoryId;
    return ref
        .watch(categoriesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => EmptyState(
            icon: Icons.folder_off_outlined,
            title: l10n.categoryLoadError,
            body: l10n.linksLoadErrorBody,
            actionLabel: l10n.tryAgain,
            onAction: () => ref.invalidate(categoriesProvider),
          ),
          data: (List<Category> categories) {
            final Category? category = categories
                .where((Category value) => value.id == categoryId)
                .firstOrNull;
            if (category == null) {
              return EmptyState(
                icon: Icons.folder_off_outlined,
                title: l10n.categoryMissingTitle,
                body: l10n.categoryMissingBody,
              );
            }
            // §22 del PRD: una categoría se puede recorrer como lista o como
            // tablero. El tablero por categoría es lo que convierte SambaLinks
            // en una herramienta de investigación por proyecto.
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.md,
                    Spacing.lg,
                    0,
                  ),
                  child: SegmentedButton<CategoryView>(
                    segments: <ButtonSegment<CategoryView>>[
                      ButtonSegment<CategoryView>(
                        value: CategoryView.list,
                        label: Text(l10n.viewList),
                        icon: const Icon(Icons.view_list_outlined),
                      ),
                      ButtonSegment<CategoryView>(
                        value: CategoryView.kanban,
                        label: Text(l10n.navKanban),
                        icon: const Icon(Icons.view_kanban_outlined),
                      ),
                    ],
                    selected: <CategoryView>{_view},
                    onSelectionChanged: (Set<CategoryView> value) =>
                        setState(() => _view = value.first),
                  ),
                ),
                Expanded(
                  child: _view == CategoryView.list
                      ? LinksListScreen(
                          key: ValueKey<String>('category-$categoryId'),
                          initialFilters: LinkListFilters(
                            categoryIds: <String>{categoryId},
                          ),
                          scopeTitle: category.name,
                          scopeSubtitle: l10n.category,
                          scopeCloseRoute: AppRoutes.categories,
                        )
                      : KanbanScreen(
                          key: ValueKey<String>('category-kanban-$categoryId'),
                          categoryId: categoryId,
                          scopeTitle: category.name,
                        ),
                ),
              ],
            );
          },
        );
  }
}
