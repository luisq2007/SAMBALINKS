import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../features/categories/domain/category.dart';
import '../../features/links/domain/enums.dart';
import '../../features/links/domain/link_card.dart' as domain;
import 'category_chip.dart';
import 'samba_card.dart';
import 'status_pill.dart';

enum LinkCardDensity { mobile, desktop, compact }

class LinkCard extends StatelessWidget {
  const LinkCard({
    required this.card,
    this.categories = const <Category>[],
    this.density = LinkCardDensity.mobile,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.onSelectionChanged,
    super.key,
  });

  final domain.LinkCard card;
  final List<Category> categories;
  final LinkCardDensity density;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (density) {
      LinkCardDensity.mobile => _MobileContent(
        card: card,
        categories: categories,
      ),
      LinkCardDensity.desktop => _DesktopContent(
        card: card,
        categories: categories,
      ),
      LinkCardDensity.compact => _CompactContent(
        card: card,
        categories: categories,
      ),
    };

    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        children: <Widget>[
          SambaCard(
            selected: selected,
            onTap: onTap,
            semanticLabel: card.displayTitle,
            padding: density == LinkCardDensity.compact
                ? const EdgeInsets.all(Spacing.md)
                : EdgeInsets.zero,
            child: content,
          ),
          if (selected || onSelectionChanged != null)
            Positioned(
              top: Spacing.sm,
              right: Spacing.sm,
              child: Semantics(
                label: L10n.of(context).cardSelectSemantics(card.displayTitle),
                child: Checkbox(
                  value: selected,
                  onChanged: (bool? value) =>
                      onSelectionChanged?.call(value ?? false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileContent extends StatelessWidget {
  const _MobileContent({required this.card, required this.categories});

  final domain.LinkCard card;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 7,
          child: _PreviewImage(card: card),
        ),
        Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: _CardDetails(card: card, categories: categories),
        ),
      ],
    );
  }
}

class _DesktopContent extends StatelessWidget {
  const _DesktopContent({required this.card, required this.categories});

  final domain.LinkCard card;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(width: 180, child: _PreviewImage(card: card)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: _CardDetails(card: card, categories: categories),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({required this.card, required this.categories});

  final domain.LinkCard card;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox.square(dimension: 48, child: _PreviewImage(card: card)),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                card.displayTitle,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                card.domain,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        StatusPill(status: card.status),
      ],
    );
  }
}

class _CardDetails extends StatelessWidget {
  const _CardDetails({required this.card, required this.categories});

  final domain.LinkCard card;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final L10n l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: Spacing.xxl),
          child: Text(
            card.displayTitle,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '${_platformLabel(l10n, card.platform)} · ${card.domain}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (card.description?.trim().isNotEmpty ?? false) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          Text(
            card.description!.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: Spacing.md),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            StatusPill(status: card.status),
            for (final Category category in categories.take(2))
              CategoryChip(category: category),
            if (card.hasNotes)
              Tooltip(
                message: l10n.cardNotesAvailable,
                child: Icon(
                  Icons.sticky_note_2_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          DateFormat.yMMMd('es').format(card.createdAt.toLocal()),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.card});

  final domain.LinkCard card;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String? localPath = card.localImage;
    final String? remoteUrl = card.imageUrl;
    final Widget fallback = _PreviewFallback(platform: card.platform);
    final Widget image;

    if (localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      image = Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      image = Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      image = fallback;
    }

    return Semantics(
      image: true,
      label: card.hasPreviewImage
          ? l10n.cardImageSemantics(card.displayTitle)
          : l10n.cardNoPreview,
      child: ClipRect(child: image),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.platform});

  final LinkPlatform platform;

  @override
  Widget build(BuildContext context) {
    final SambaColors samba = Theme.of(context).extension<SambaColors>()!;
    return ColoredBox(
      color: samba.surfaceElevated,
      child: Center(
        child: Icon(
          _platformIcon(platform),
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

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

IconData _platformIcon(LinkPlatform platform) => switch (platform) {
  LinkPlatform.youtube => Icons.play_circle_outline,
  LinkPlatform.instagram => Icons.photo_camera_outlined,
  LinkPlatform.x || LinkPlatform.threads => Icons.alternate_email,
  LinkPlatform.pinterest => Icons.push_pin_outlined,
  LinkPlatform.facebook || LinkPlatform.linkedin => Icons.people_outline,
  LinkPlatform.tiktok => Icons.music_note,
  LinkPlatform.reddit => Icons.forum_outlined,
  LinkPlatform.web || LinkPlatform.other => Icons.language,
};
