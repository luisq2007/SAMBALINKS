import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/samba_button.dart';
import '../../../shared/widgets/samba_sheet.dart';
import '../domain/enums.dart';
import 'link_list_filters.dart';

class LinkFiltersSheet extends StatefulWidget {
  const LinkFiltersSheet({
    required this.initial,
    required this.options,
    super.key,
  });

  final LinkListFilters initial;
  final LinkFilterOptions options;

  static Future<LinkListFilters?> show({
    required BuildContext context,
    required LinkListFilters initial,
    required LinkFilterOptions options,
  }) {
    return SambaSheet.show<LinkListFilters>(
      context: context,
      builder: (BuildContext context) =>
          LinkFiltersSheet(initial: initial, options: options),
    );
  }

  @override
  State<LinkFiltersSheet> createState() => _LinkFiltersSheetState();
}

class _LinkFiltersSheetState extends State<LinkFiltersSheet> {
  late Set<CardStatus> _statuses;
  late Set<LinkPlatform> _platforms;
  late Set<String> _categoryIds;
  late LinkDateFilter _date;
  bool? _hasImage;
  bool? _hasNotes;
  late bool _uncategorized;

  @override
  void initState() {
    super.initState();
    _reset(widget.initial);
  }

  void _reset(LinkListFilters value) {
    _statuses = <CardStatus>{...value.statuses};
    _platforms = <LinkPlatform>{...value.platforms};
    _categoryIds = <String>{...value.categoryIds};
    _date = value.date;
    _hasImage = value.hasImage;
    _hasNotes = value.hasNotes;
    _uncategorized = value.uncategorized;
  }

  LinkListFilters get _value => LinkListFilters(
    statuses: _statuses,
    platforms: _platforms,
    categoryIds: _categoryIds,
    date: _date,
    hasImage: _hasImage,
    hasNotes: _hasNotes,
    uncategorized: _uncategorized,
  );

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return SambaSheet(
      title: l10n.filterSheetTitle,
      actions: <Widget>[
        SambaButton(
          label: l10n.clearFilters,
          variant: SambaButtonVariant.ghost,
          onPressed: () => setState(() => _reset(LinkListFilters.empty)),
        ),
        SambaButton(
          label: l10n.filterApply,
          icon: Icons.check,
          onPressed: () => Navigator.of(context).pop(_value),
        ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.62,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Section(
                title: l10n.filterStatus,
                child: Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: <Widget>[
                    for (final CardStatus status in CardStatus.values)
                      FilterChip(
                        label: Text(_statusLabel(l10n, status)),
                        selected: _statuses.contains(status),
                        onSelected: (bool selected) => setState(() {
                          selected
                              ? _statuses.add(status)
                              : _statuses.remove(status);
                        }),
                      ),
                  ],
                ),
              ),
              _Section(
                title: l10n.filterPlatform,
                child: Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: <Widget>[
                    for (final LinkPlatform platform in LinkPlatform.values)
                      FilterChip(
                        label: Text(_platformLabel(l10n, platform)),
                        selected: _platforms.contains(platform),
                        onSelected: (bool selected) => setState(() {
                          selected
                              ? _platforms.add(platform)
                              : _platforms.remove(platform);
                        }),
                      ),
                  ],
                ),
              ),
              if (widget.options.categories.isNotEmpty)
                _Section(
                  title: l10n.filterCategory,
                  child: Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: <Widget>[
                      for (final category in widget.options.categories)
                        CategoryChip(
                          category: category,
                          selected: _categoryIds.contains(category.id),
                          onPressed: () => setState(() {
                            _categoryIds.contains(category.id)
                                ? _categoryIds.remove(category.id)
                                : _categoryIds.add(category.id);
                          }),
                        ),
                    ],
                  ),
                ),
              _Section(
                title: l10n.filterDate,
                child: DropdownButtonFormField<LinkDateFilter>(
                  initialValue: _date,
                  items: <DropdownMenuItem<LinkDateFilter>>[
                    for (final LinkDateFilter value in LinkDateFilter.values)
                      DropdownMenuItem<LinkDateFilter>(
                        value: value,
                        child: Text(_dateLabel(l10n, value)),
                      ),
                  ],
                  onChanged: (LinkDateFilter? value) {
                    if (value != null) {
                      setState(() => _date = value);
                    }
                  },
                ),
              ),
              _TriStateSection(
                title: l10n.filterPreview,
                value: _hasImage,
                trueLabel: l10n.filterWithImage,
                falseLabel: l10n.filterWithoutImage,
                onChanged: (bool? value) => setState(() => _hasImage = value),
              ),
              _TriStateSection(
                title: l10n.filterNotes,
                value: _hasNotes,
                trueLabel: l10n.filterWithNotes,
                falseLabel: l10n.filterWithoutNotes,
                onChanged: (bool? value) => setState(() => _hasNotes = value),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _uncategorized,
                title: Text(l10n.filterUncategorized),
                onChanged: (bool? value) =>
                    setState(() => _uncategorized = value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: Spacing.sm),
          child,
        ],
      ),
    );
  }
}

class _TriStateSection extends StatelessWidget {
  const _TriStateSection({
    required this.title,
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  final String title;
  final bool? value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return _Section(
      title: title,
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: <Widget>[
          ChoiceChip(
            label: Text(l10n.filterAny),
            selected: value == null,
            onSelected: (_) => onChanged(null),
          ),
          ChoiceChip(
            label: Text(trueLabel),
            selected: value == true,
            onSelected: (_) => onChanged(true),
          ),
          ChoiceChip(
            label: Text(falseLabel),
            selected: value == false,
            onSelected: (_) => onChanged(false),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(L10n l10n, CardStatus status) => switch (status) {
  CardStatus.pending => l10n.statusPending,
  CardStatus.active => l10n.statusActive,
  CardStatus.done => l10n.statusDone,
};

String _platformLabel(L10n l10n, LinkPlatform platform) => switch (platform) {
  LinkPlatform.instagram => l10n.platformInstagram,
  LinkPlatform.x => l10n.platformX,
  LinkPlatform.threads => l10n.platformThreads,
  LinkPlatform.pinterest => l10n.platformPinterest,
  LinkPlatform.facebook => l10n.platformFacebook,
  LinkPlatform.tiktok => l10n.platformTikTok,
  LinkPlatform.youtube => l10n.platformYouTube,
  LinkPlatform.linkedin => l10n.platformLinkedIn,
  LinkPlatform.reddit => l10n.platformReddit,
  LinkPlatform.web => l10n.platformWeb,
  LinkPlatform.other => l10n.platformOther,
};

String _dateLabel(L10n l10n, LinkDateFilter value) => switch (value) {
  LinkDateFilter.any => l10n.filterDateAny,
  LinkDateFilter.today => l10n.filterDateToday,
  LinkDateFilter.last7Days => l10n.filterDateLast7Days,
  LinkDateFilter.last30Days => l10n.filterDateLast30Days,
};
