import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/category_icon_catalog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/samba_button.dart';
import '../../../shared/widgets/samba_card.dart';
import '../../../shared/widgets/samba_menu.dart';
import '../../../shared/widgets/samba_sheet.dart';
import '../../../shared/widgets/samba_text_field.dart';
import '../../links/domain/link_card.dart';
import '../../links/domain/link_query.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final List<String> _localOrder = <String>[];

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<CategorySummary>> value = ref.watch(
      categorySummariesProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.xl,
            Spacing.lg,
            Spacing.xl,
            Spacing.sm,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Spacing.lg,
            runSpacing: Spacing.sm,
            children: <Widget>[
              Text(
                l10n.categories,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SambaButton(
                label: l10n.categoryNew,
                icon: Icons.create_new_folder_outlined,
                onPressed: _editCategory,
              ),
            ],
          ),
        ),
        Expanded(
          child: value.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => EmptyState(
              icon: Icons.folder_off_outlined,
              title: l10n.categoryLoadError,
              body: l10n.linksLoadErrorBody,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(categorySummariesProvider),
            ),
            data: (List<CategorySummary> source) {
              if (source.isEmpty) {
                return EmptyState(
                  icon: Icons.folder_outlined,
                  title: l10n.categoriesEmptyTitle,
                  body: l10n.categoriesEmptyBody,
                  actionLabel: l10n.categoryCreateFirst,
                  onAction: _editCategory,
                );
              }
              final List<CategorySummary> summaries = _ordered(source);
              return ReorderableListView.builder(
                key: const ValueKey<String>('categories-list'),
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.sm,
                  Spacing.xl,
                  Spacing.xxl,
                ),
                buildDefaultDragHandles: false,
                itemCount: summaries.length,
                onReorder: (int oldIndex, int newIndex) =>
                    _reorder(summaries, oldIndex, newIndex),
                itemBuilder: (BuildContext context, int index) {
                  final CategorySummary summary = summaries[index];
                  return Padding(
                    key: ValueKey<String>(summary.category.id),
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: _CategoryRow(
                      summary: summary,
                      index: index,
                      onOpen: () =>
                          context.go(AppRoutes.category(summary.category.id)),
                      onEdit: () => _editCategory(summary.category),
                      onDelete: () => _deleteCategory(summary.category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<CategorySummary> _ordered(List<CategorySummary> source) {
    if (_localOrder.isEmpty) {
      return source;
    }
    final Map<String, CategorySummary> byId = <String, CategorySummary>{
      for (final CategorySummary summary in source)
        summary.category.id: summary,
    };
    return <CategorySummary>[
      for (final String id in _localOrder)
        if (byId.remove(id) case final CategorySummary summary) summary,
      ...byId.values,
    ];
  }

  void _reorder(List<CategorySummary> source, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final List<String> ids = source
        .map((CategorySummary summary) => summary.category.id)
        .toList();
    final String moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    setState(() {
      _localOrder
        ..clear()
        ..addAll(ids);
    });
    unawaited(ref.read(categoryRepositoryProvider).reorder(ids));
  }

  Future<void> _editCategory([Category? category]) async {
    final _CategoryDraft? draft = await _CategoryEditorSheet.show(
      context: context,
      category: category,
    );
    if (draft == null || !mounted) {
      return;
    }
    final L10n l10n = L10n.of(context);
    final CategoryRepository repository = ref.read(categoryRepositoryProvider);
    final List<Category> existing =
        ref.read(categoriesProvider).asData?.value ?? const <Category>[];
    final bool duplicate = existing.any(
      (Category value) =>
          value.id != category?.id &&
          value.name.trim().toLowerCase() == draft.name.toLowerCase(),
    );
    if (duplicate) {
      _message(l10n.categoryDuplicate);
      return;
    }

    try {
      if (category == null) {
        final Result<Category> result = await repository.create(
          name: draft.name,
          color: draft.color,
          icon: draft.icon,
        );
        if (result.failureOrNull is DuplicateCategoryFailure) {
          _message(l10n.categoryDuplicate);
        } else if (!result.isSuccess) {
          _message(l10n.categorySaveError);
        }
      } else {
        await repository.update(
          category.copyWith(
            name: draft.name,
            color: draft.color,
            icon: draft.icon,
          ),
        );
      }
    } on Object {
      _message(l10n.categorySaveError);
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CategoryRepository categories = ref.read(categoryRepositoryProvider);
    final links = ref.read(linkRepositoryProvider);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.folder_delete_outlined),
        title: Text(l10n.categoryDeleteTitle(category.name)),
        content: Text(l10n.categoryDeleteBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final List<LinkCard> assigned = await links
        .watchLinks(
          filter: CardFilter(categoryIds: <String>{category.id}),
          sort: CardSort.newest,
          offset: 0,
        )
        .first;
    await categories.delete(category.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.categoryDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () =>
                unawaited(_restoreCategory(category, assigned, categories)),
          ),
        ),
      );
  }

  Future<void> _restoreCategory(
    Category category,
    List<LinkCard> assigned,
    CategoryRepository repository,
  ) async {
    await repository.update(category);
    for (final LinkCard card in assigned) {
      await repository.assign(cardId: card.id, categoryId: category.id);
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    }
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.summary,
    required this.index,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CategorySummary summary;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final Category category = summary.category;
    final Color color =
        SambaPalette.tryParseHex(category.color) ??
        Theme.of(context).colorScheme.secondaryContainer;
    return SambaCard(
      onTap: onOpen,
      semanticLabel: l10n.categoryOpen(category.name),
      child: Row(
        children: <Widget>[
          Container(
            width: TouchTargets.minimum,
            height: TouchTargets.minimum,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Radii.chip),
            ),
            child: Icon(
              CategoryIconCatalog.fromKey(category.icon),
              color:
                  ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                  ? SambaPalette.white
                  : SambaPalette.raven,
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.categoryLinkCount(summary.linkCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SambaMenu<_CategoryAction>(
            tooltip: l10n.categoryActions(category.name),
            icon: Icons.more_vert,
            items: <SambaMenuItem<_CategoryAction>>[
              SambaMenuItem<_CategoryAction>(
                value: _CategoryAction.edit,
                label: l10n.edit,
                icon: Icons.edit_outlined,
              ),
              SambaMenuItem<_CategoryAction>(
                value: _CategoryAction.delete,
                label: l10n.delete,
                icon: Icons.delete_outline,
                destructive: true,
              ),
            ],
            onSelected: (_CategoryAction action) => switch (action) {
              _CategoryAction.edit => onEdit(),
              _CategoryAction.delete => onDelete(),
            },
          ),
          Semantics(
            label: l10n.categoryReorder(category.name),
            button: true,
            child: ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: TouchTargets.minimum,
                height: TouchTargets.minimum,
                child: Icon(Icons.drag_handle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final Category? category;

  static Future<_CategoryDraft?> show({
    required BuildContext context,
    Category? category,
  }) {
    return SambaSheet.show<_CategoryDraft>(
      context: context,
      builder: (BuildContext context) =>
          _CategoryEditorSheet(category: category),
    );
  }

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.category?.name ?? '',
  );
  late String _color = widget.category?.color ?? '#B9ECFA';
  late String _icon = widget.category?.icon ?? 'folder';
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return SambaSheet(
      title: widget.category == null ? l10n.categoryNew : l10n.categoryEdit,
      actions: <Widget>[
        SambaButton(
          label: l10n.cancel,
          variant: SambaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SambaButton(label: l10n.save, icon: Icons.check, onPressed: _save),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SambaTextField(
              controller: _name,
              label: l10n.categoryName,
              hint: l10n.categoryNameHint,
              errorText: _error,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              l10n.categoryColor,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: <Widget>[
                for (final (int index, MapEntry<String, Color> entry)
                    in SambaPalette.categoryChoices.entries.indexed)
                  Semantics(
                    label: l10n.categoryColorOption(index + 1),
                    selected: _color == entry.key,
                    button: true,
                    child: ChoiceChip(
                      label: SizedBox.square(
                        dimension: 24,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                      selected: _color == entry.key,
                      onSelected: (_) => setState(() => _color = entry.key),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              l10n.categoryIcon,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: <Widget>[
                for (final (int index, CategoryIconChoice choice)
                    in CategoryIconCatalog.choices.indexed)
                  Semantics(
                    label: l10n.categoryIconOption(index + 1),
                    selected: _icon == choice.key,
                    button: true,
                    child: ChoiceChip(
                      label: Icon(choice.icon),
                      selected: _icon == choice.key,
                      onSelected: (_) => setState(() => _icon = choice.key),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = L10n.of(context).categoryNameRequired);
      return;
    }
    Navigator.of(
      context,
    ).pop(_CategoryDraft(name: name, color: _color, icon: _icon));
  }
}

class _CategoryDraft {
  const _CategoryDraft({
    required this.name,
    required this.color,
    required this.icon,
  });

  final String name;
  final String color;
  final String icon;
}

enum _CategoryAction { edit, delete }
