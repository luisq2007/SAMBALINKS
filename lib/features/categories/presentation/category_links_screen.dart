import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../links/presentation/link_list_filters.dart';
import '../../links/presentation/links_list_screen.dart';
import '../domain/category.dart';

class CategoryLinksScreen extends ConsumerWidget {
  const CategoryLinksScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
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
            return LinksListScreen(
              key: ValueKey<String>('category-$categoryId'),
              initialFilters: LinkListFilters(
                categoryIds: <String>{categoryId},
              ),
              scopeTitle: category.name,
              scopeSubtitle: l10n.category,
              scopeCloseRoute: AppRoutes.categories,
            );
          },
        );
  }
}
