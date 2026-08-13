import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../../features/categories/domain/category.dart';
import '../../../features/links/domain/enums.dart';
import '../../../shared/widgets/widgets.dart';

class DesignSystemGallery extends StatelessWidget {
  const DesignSystemGallery({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devGalleryTitle),
        actions: <Widget>[
          IconButton(
            onPressed: onToggleTheme,
            tooltip: l10n.devGalleryThemeTooltip,
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 900;
          final double availableWidth = constraints.maxWidth
              .clamp(0.0, 1200.0)
              .toDouble();
          final double itemWidth = wide
              ? (availableWidth - Spacing.xxl) / 2
              : double.infinity;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.xxl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Wrap(
                  spacing: Spacing.xxl,
                  runSpacing: Spacing.xxl,
                  children: <Widget>[
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryButtons,
                        child: const _ButtonsSample(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryFields,
                        child: const _FieldsSample(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryStatuses,
                        child: const Wrap(
                          spacing: Spacing.sm,
                          runSpacing: Spacing.sm,
                          children: <Widget>[
                            StatusPill(status: CardStatus.pending),
                            StatusPill(status: CardStatus.active),
                            StatusPill(status: CardStatus.done),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryCategories,
                        child: const _CategoriesSample(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryCards,
                        child: const _CardSample(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryOverlays,
                        child: const _OverlaysSample(),
                      ),
                    ),
                    SizedBox(
                      width: wide ? availableWidth : itemWidth,
                      child: _GallerySection(
                        title: l10n.devGalleryEmptyStates,
                        child: SizedBox(
                          height: 420,
                          child: EmptyState(
                            icon: Icons.bookmarks_outlined,
                            title: l10n.devGalleryEmptyTitle,
                            body: l10n.devGalleryEmptyBody,
                            actionLabel: l10n.addFirstLink,
                            onAction: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SambaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Spacing.xl),
          child,
        ],
      ),
    );
  }
}

class _ButtonsSample extends StatelessWidget {
  const _ButtonsSample();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: <Widget>[
        SambaButton(label: l10n.save, onPressed: () {}, icon: Icons.check),
        SambaButton(
          label: l10n.devGallerySecondaryAction,
          onPressed: () {},
          variant: SambaButtonVariant.secondary,
        ),
        SambaButton(
          label: l10n.devGalleryGhostAction,
          onPressed: () {},
          variant: SambaButtonVariant.ghost,
        ),
        SambaButton(
          label: l10n.devGalleryDeleteAction,
          onPressed: () {},
          icon: Icons.delete_outline,
          variant: SambaButtonVariant.danger,
        ),
        SambaButton(
          label: l10n.devGalleryLoading,
          onPressed: () {},
          loading: true,
        ),
      ],
    );
  }
}

class _FieldsSample extends StatelessWidget {
  const _FieldsSample();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Column(
      children: <Widget>[
        SambaTextField(
          label: l10n.devGalleryTitleField,
          hint: l10n.devGalleryTitleHint,
          prefixIcon: const Icon(Icons.link),
        ),
        const SizedBox(height: Spacing.lg),
        SambaTextField(
          label: l10n.devGalleryNotesField,
          hint: l10n.devGalleryNotesHint,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _CategoriesSample extends StatelessWidget {
  const _CategoriesSample();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final DateTime now = DateTime.utc(2026, 8, 12);
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: <Widget>[
        CategoryChip(
          category: Category(
            id: 'read',
            name: l10n.devGalleryCategoryReadLater,
            color: '#B9ECFA',
            createdAt: now,
            updatedAt: now,
          ),
          selected: true,
          onPressed: () {},
        ),
        CategoryChip(
          category: Category(
            id: 'ideas',
            name: l10n.devGalleryCategoryInspiration,
            color: '#B9F7D8',
            createdAt: now,
            updatedAt: now,
          ),
          onPressed: () {},
          onDeleted: () {},
        ),
      ],
    );
  }
}

class _CardSample extends StatelessWidget {
  const _CardSample();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    return SambaCard(
      onTap: () {},
      semanticLabel: l10n.devGallerySampleCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.devGallerySampleCardTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              SambaMenu<String>(
                tooltip: l10n.devGalleryMenuTooltip,
                items: <SambaMenuItem<String>>[
                  SambaMenuItem<String>(
                    value: 'open',
                    label: l10n.openOriginal,
                    icon: Icons.open_in_new,
                  ),
                  SambaMenuItem<String>(
                    value: 'delete',
                    label: l10n.delete,
                    icon: Icons.delete_outline,
                    destructive: true,
                  ),
                ],
                onSelected: _ignoreSelection,
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.devGallerySampleCardBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: <Widget>[
              const StatusPill(status: CardStatus.active),
              const Spacer(),
              Text(
                l10n.devGallerySampleDomain,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _ignoreSelection(String _) {}
}

class _OverlaysSample extends StatelessWidget {
  const _OverlaysSample();

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return Row(
      children: <Widget>[
        SambaButton(
          label: l10n.devGalleryOpenSheet,
          onPressed: () {
            SambaSheet.show<void>(
              context: context,
              builder: (BuildContext context) => SambaSheet(
                title: l10n.devGallerySheetTitle,
                actions: <Widget>[
                  SambaButton(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    variant: SambaButtonVariant.ghost,
                  ),
                  SambaButton(
                    label: l10n.save,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
                child: Text(l10n.devGallerySheetBody),
              ),
            );
          },
          variant: SambaButtonVariant.secondary,
        ),
        const Spacer(),
        SambaMenu<String>(
          tooltip: l10n.devGalleryMenuTooltip,
          onSelected: (_) {},
          items: <SambaMenuItem<String>>[
            SambaMenuItem<String>(
              value: 'open',
              label: l10n.openOriginal,
              icon: Icons.open_in_new,
            ),
            SambaMenuItem<String>(
              value: 'copy',
              label: l10n.copyUrl,
              icon: Icons.copy,
            ),
            SambaMenuItem<String>(
              value: 'delete',
              label: l10n.delete,
              icon: Icons.delete_outline,
              destructive: true,
            ),
          ],
        ),
      ],
    );
  }
}
