import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/samba_button.dart';
import '../../../shared/widgets/samba_sheet.dart';
import '../../../shared/widgets/samba_text_field.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../categories/domain/category.dart';
import '../../categories/domain/category_repository.dart';
import '../../metadata/domain/metadata_refresh_outcome.dart';
import '../domain/enums.dart';
import '../domain/link_card.dart';
import '../domain/link_repository.dart';
import 'link_selection_provider.dart';

class LinkDetailHost extends ConsumerWidget {
  const LinkDetailHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LinkCard? card = ref.watch(selectedLinkProvider);
    if (card == null) {
      final L10n l10n = L10n.of(context);
      return EmptyState(
        icon: Icons.vertical_split_outlined,
        title: l10n.wideDetailTitle,
        body: l10n.wideDetailBody,
      );
    }
    return LinkDetailPane(card: card);
  }
}

class LinkDetailPane extends ConsumerStatefulWidget {
  const LinkDetailPane({
    required this.card,
    this.closeOnDelete = false,
    this.scrollController,
    super.key,
  });

  final LinkCard card;
  final bool closeOnDelete;
  final ScrollController? scrollController;

  static Future<void> show(BuildContext context, LinkCard card) {
    return SambaSheet.show<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.5,
        initialChildSize: 0.78,
        maxChildSize: 0.96,
        builder: (BuildContext context, ScrollController controller) =>
            LinkDetailPane(
              card: card,
              closeOnDelete: true,
              scrollController: controller,
            ),
      ),
    );
  }

  @override
  ConsumerState<LinkDetailPane> createState() => _LinkDetailPaneState();
}

class _LinkDetailPaneState extends ConsumerState<LinkDetailPane> {
  final FocusNode _titleFocus = FocusNode();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late LinkCard _card;
  Timer? _saveDebounce;
  bool _saving = false;
  bool _refreshing = false;
  bool _saved = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    _title = TextEditingController(text: _card.title ?? '');
    _description = TextEditingController(text: _card.description ?? '');
    _notes = TextEditingController(text: _card.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant LinkDetailPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      _saveDebounce?.cancel();
      _replaceCard(widget.card);
    } else if (widget.card.updatedAt != oldWidget.card.updatedAt && !_saving) {
      _card = widget.card;
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (_hasDraftChanges && !_saving) {
      final LinkRepository repository = ref.read(linkRepositoryProvider);
      final LinkCard draft = _draft;
      unawaited(repository.update(draft));
    }
    _titleFocus.dispose();
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _hasDraftChanges =>
      _clean(_card.title) != _clean(_title.text) ||
      _clean(_card.description) != _clean(_description.text) ||
      _clean(_card.notes) != _clean(_notes.text);

  String? _clean(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  LinkCard get _draft => _card.copyWith(
    title: _clean(_title.text),
    description: _clean(_description.text),
    notes: _clean(_notes.text),
  );

  void _scheduleSave(String _) {
    _saveDebounce?.cancel();
    setState(() {
      _saved = false;
      _saveError = null;
    });
    _saveDebounce = Timer(const Duration(milliseconds: 800), _persistDraft);
  }

  Future<void> _persistDraft({bool showFeedback = true}) async {
    if (!_hasDraftChanges) {
      return;
    }
    if (showFeedback && mounted) {
      setState(() {
        _saving = true;
        _saveError = null;
      });
    }
    final LinkRepository repository = ref.read(linkRepositoryProvider);
    final LinkCard draft = _draft;
    try {
      final LinkCard stored = await repository.update(draft);
      if (!mounted) {
        return;
      }
      _card = stored;
      ref.read(selectedLinkProvider.notifier).select(stored);
      if (showFeedback && mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }
    } on Object {
      if (showFeedback && mounted) {
        setState(() {
          _saving = false;
          _saveError = L10n.of(context).detailSaveError;
        });
      }
    }
  }

  void _replaceCard(LinkCard card) {
    _card = card;
    _title.text = card.title ?? '';
    _description.text = card.description ?? '';
    _notes.text = card.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final List<Category> categories =
        ref.watch(categoriesOfProvider(_card.id)).asData?.value ??
        const <Category>[];
    final bool metadataFailed = _card.metadataStatus == MetadataStatus.failed;

    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _card.displayTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _card.domain,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DetailAction>(
                tooltip: l10n.detailMoreActions,
                onSelected: _handleAction,
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<_DetailAction>>[
                      for (final _DetailAction action in _DetailAction.values)
                        PopupMenuItem<_DetailAction>(
                          value: action,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(_actionIcon(action)),
                            title: Text(_actionLabel(l10n, action)),
                          ),
                        ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: <Widget>[
              StatusPill(status: _card.status),
              for (final Category category in categories)
                CategoryChip(category: category),
            ],
          ),
          if (metadataFailed) ...<Widget>[
            const SizedBox(height: Spacing.md),
            _MetadataError(onRetry: _refreshMetadata),
          ],
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                child: Column(
                  children: <Widget>[
                    SambaTextField(
                      controller: _title,
                      label: l10n.detailTitleField,
                      focusNode: _titleFocus,
                      onChanged: _scheduleSave,
                    ),
                    const SizedBox(height: Spacing.md),
                    SambaTextField(
                      controller: _description,
                      label: l10n.detailDescriptionField,
                      maxLines: 4,
                      onChanged: _scheduleSave,
                    ),
                    const SizedBox(height: Spacing.md),
                    SambaTextField(
                      controller: _notes,
                      label: l10n.detailNotesField,
                      maxLines: 6,
                      onChanged: _scheduleSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_saving || _saved || _saveError != null) ...<Widget>[
            const SizedBox(height: Spacing.sm),
            Text(
              _saving ? l10n.detailSaving : _saveError ?? l10n.detailSaved,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _saveError == null
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: <Widget>[
              SambaButton(
                label: l10n.openOriginal,
                variant: SambaButtonVariant.secondary,
                icon: Icons.open_in_new,
                onPressed: _openOriginal,
              ),
              SambaButton(
                label: _refreshing
                    ? l10n.metadataRefreshing
                    : l10n.refreshPreview,
                icon: Icons.refresh,
                loading: _refreshing,
                onPressed: _refreshMetadata,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(_DetailAction action) async {
    final L10n l10n = L10n.of(context);
    switch (action) {
      case _DetailAction.openOriginal:
        await _openOriginal();
      case _DetailAction.copyUrl:
        await Clipboard.setData(ClipboardData(text: _card.url));
        _message(l10n.urlCopied);
      case _DetailAction.share:
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        await SharePlus.instance.share(
          ShareParams(
            text: _card.url,
            subject: _card.displayTitle,
            sharePositionOrigin: box == null
                ? null
                : box.localToGlobal(Offset.zero) & box.size,
          ),
        );
      case _DetailAction.edit:
        _titleFocus.requestFocus();
      case _DetailAction.copyMarkdown:
        await Clipboard.setData(
          ClipboardData(text: '[${_card.displayTitle}](${_card.url})'),
        );
        _message(l10n.markdownCopied);
      case _DetailAction.pending:
        await _changeStatus(CardStatus.pending);
      case _DetailAction.active:
        await _changeStatus(CardStatus.active);
      case _DetailAction.done:
        await _changeStatus(CardStatus.done);
      case _DetailAction.refresh:
        await _refreshMetadata();
      case _DetailAction.categories:
        await _editCategories();
      case _DetailAction.delete:
        await _delete();
    }
  }

  Future<void> _openOriginal() async {
    final String errorMessage = L10n.of(context).openOriginalError;
    final Uri? uri = Uri.tryParse(_card.url);
    final bool opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      _message(errorMessage);
    }
  }

  Future<void> _changeStatus(CardStatus status) async {
    final LinkRepository repository = ref.read(linkRepositoryProvider);
    await repository.updateStatus(_card.id, status);
    if (!mounted) {
      return;
    }
    final LinkCard next = _card.copyWith(status: status);
    setState(() => _card = next);
    ref.read(selectedLinkProvider.notifier).select(next);
  }

  Future<void> _refreshMetadata() async {
    if (_refreshing) {
      return;
    }
    _saveDebounce?.cancel();
    await _persistDraft();
    if (!mounted || _hasDraftChanges) {
      return;
    }
    final L10n l10n = L10n.of(context);
    final service = ref.read(metadataEnrichmentServiceProvider);
    setState(() => _refreshing = true);
    try {
      final MetadataRefreshOutcome outcome = await service.refreshCard(
        _card.id,
      );
      if (!mounted) {
        return;
      }
      final LinkCard? updated = switch (outcome) {
        MetadataRefreshUpdated(:final LinkCard card) => card,
        MetadataRefreshDuplicate(:final LinkCard card) => card,
        MetadataRefreshCardNotFound() => null,
      };
      if (updated == null) {
        setState(() => _refreshing = false);
        _message(l10n.detailRefreshError);
      } else {
        setState(() {
          _replaceCard(updated);
          _refreshing = false;
        });
        ref.read(selectedLinkProvider.notifier).select(updated);
        _message(l10n.detailRefreshSuccess);
      }
    } on Object {
      if (mounted) {
        setState(() => _refreshing = false);
        _message(l10n.detailRefreshError);
      }
    }
  }

  Future<void> _editCategories() async {
    final List<Category> all = await ref.read(categoriesProvider.future);
    final List<Category> current = await ref.read(
      categoriesOfProvider(_card.id).future,
    );
    if (!mounted) {
      return;
    }
    final Set<String>? selected = await SambaSheet.show<Set<String>>(
      context: context,
      builder: (BuildContext context) => _CategoryPicker(
        categories: all,
        selectedIds: current.map((Category value) => value.id).toSet(),
      ),
    );
    if (selected != null && mounted) {
      await ref
          .read(categoryRepositoryProvider)
          .setCategoriesOf(_card.id, selected);
    }
  }

  Future<void> _delete() async {
    final L10n l10n = L10n.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final LinkRepository links = ref.read(linkRepositoryProvider);
    final CategoryRepository categoryRepository = ref.read(
      categoryRepositoryProvider,
    );
    final SelectedLinkController selection = ref.read(
      selectedLinkProvider.notifier,
    );
    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.detailDeleteConfirmTitle),
        content: Text(l10n.detailDeleteConfirmBody),
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
    _saveDebounce?.cancel();
    await _persistDraft();
    if (!mounted || _hasDraftChanges) {
      return;
    }
    final LinkCard deleted = _card;
    final List<Category> categories = await ref.read(
      categoriesOfProvider(deleted.id).future,
    );
    if (!mounted) {
      return;
    }
    await links.delete(deleted.id);
    if (!mounted) {
      return;
    }
    selection.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.detailDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => unawaited(
              _restore(
                links: links,
                categoryRepository: categoryRepository,
                selection: selection,
                card: deleted,
                categories: categories,
              ),
            ),
          ),
        ),
      );
    if (widget.closeOnDelete && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _restore({
    required LinkRepository links,
    required CategoryRepository categoryRepository,
    required SelectedLinkController selection,
    required LinkCard card,
    required List<Category> categories,
  }) async {
    final Result<LinkCard> result = await links.create(card);
    if (result.isSuccess) {
      await categoryRepository.setCategoriesOf(
        card.id,
        categories.map((Category category) => category.id).toSet(),
      );
      selection.select(card);
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

class _MetadataError extends StatelessWidget {
  const _MetadataError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    return ColoredBox(
      color: samba.dangerBg,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: samba.dangerFg),
            const SizedBox(width: Spacing.sm),
            Expanded(child: Text(l10n.detailRefreshError)),
            TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatefulWidget {
  const _CategoryPicker({required this.categories, required this.selectedIds});

  final List<Category> categories;
  final Set<String> selectedIds;

  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  late final Set<String> _selected = <String>{...widget.selectedIds};

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return SambaSheet(
      title: l10n.detailManageCategories,
      actions: <Widget>[
        SambaButton(
          label: l10n.categoriesApply,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
      child: SingleChildScrollView(
        child: Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: <Widget>[
            for (final Category category in widget.categories)
              CategoryChip(
                category: category,
                selected: _selected.contains(category.id),
                onPressed: () => setState(() {
                  _selected.contains(category.id)
                      ? _selected.remove(category.id)
                      : _selected.add(category.id);
                }),
              ),
          ],
        ),
      ),
    );
  }
}

enum _DetailAction {
  openOriginal,
  copyUrl,
  share,
  edit,
  copyMarkdown,
  pending,
  active,
  done,
  refresh,
  categories,
  delete,
}

String _actionLabel(L10n l10n, _DetailAction action) => switch (action) {
  _DetailAction.openOriginal => l10n.openOriginal,
  _DetailAction.copyUrl => l10n.copyUrl,
  _DetailAction.share => l10n.shareLink,
  _DetailAction.edit => l10n.detailEdit,
  _DetailAction.copyMarkdown => l10n.copyAsMarkdown,
  _DetailAction.pending => l10n.statusPending,
  _DetailAction.active => l10n.statusActive,
  _DetailAction.done => l10n.statusDone,
  _DetailAction.refresh => l10n.refreshPreview,
  _DetailAction.categories => l10n.detailManageCategories,
  _DetailAction.delete => l10n.delete,
};

IconData _actionIcon(_DetailAction action) => switch (action) {
  _DetailAction.openOriginal => Icons.open_in_new,
  _DetailAction.copyUrl => Icons.link,
  _DetailAction.share => Icons.share_outlined,
  _DetailAction.edit => Icons.edit_outlined,
  _DetailAction.copyMarkdown => Icons.code,
  _DetailAction.pending => Icons.schedule,
  _DetailAction.active => Icons.play_arrow,
  _DetailAction.done => Icons.check,
  _DetailAction.refresh => Icons.refresh,
  _DetailAction.categories => Icons.folder_outlined,
  _DetailAction.delete => Icons.delete_outline,
};
