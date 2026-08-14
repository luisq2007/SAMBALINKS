import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart'
    show SambaButton, SambaButtonVariant, SambaTextField, StatusPill;
import '../../categories/domain/category.dart';
import '../../links/domain/enums.dart';
import '../../links/domain/link_card.dart';
import '../domain/incoming_share.dart';

/// Quick Save (§7 del PRD): lo que aparece al compartir algo hacia SambaLinks.
///
/// **Ningún campo es obligatorio.** El flujo mínimo es Compartir → Guardar; el
/// estado nace en Pendiente y sin categoría, o sea, en la Bandeja.
class QuickSaveSheet extends ConsumerStatefulWidget {
  const QuickSaveSheet({required this.share, super.key});

  final IncomingShare share;

  /// Devuelve el enlace guardado, o `null` si se cerró sin guardar.
  static Future<LinkCard?> show(BuildContext context, IncomingShare share) {
    return showModalBottomSheet<LinkCard>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => QuickSaveSheet(share: share),
    );
  }

  @override
  ConsumerState<QuickSaveSheet> createState() => _QuickSaveSheetState();
}

class _QuickSaveSheetState extends ConsumerState<QuickSaveSheet> {
  final TextEditingController _note = TextEditingController();
  final Set<String> _categoryIds = <String>{};

  CardStatus _status = CardStatus.pending;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final L10n l10n = L10n.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Result<LinkCard> result = await ref
        .read(linkSaverProvider)
        .save(
          rawUrl: widget.share.url ?? widget.share.rawText,
          note: _note.text,
          status: _status,
          categoryIds: _categoryIds,
          // El texto íntegro que envió la otra app suele llevar contexto que el
          // usuario puede querer recuperar.
          originalSharedText: widget.share.rawText,
        );

    if (!mounted) {
      return;
    }

    result.fold(
      onSuccess: (LinkCard card) {
        navigator.pop(card);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(_savedMessage(l10n))));
      },
      onFailure: (AppFailure failure) {
        setState(() {
          _saving = false;
          _error = switch (failure) {
            DuplicateLinkFailure() => l10n.addLinkDuplicateTitle,
            InvalidUrlFailure() => l10n.addLinkInvalid,
            _ => l10n.quickSaveError,
          };
        });
      },
    );
  }

  String _savedMessage(L10n l10n) {
    if (_categoryIds.isEmpty) {
      return l10n.quickSaveSaved;
    }
    final List<Category> all =
        ref.read(categoriesProvider).asData?.value ?? const <Category>[];
    final Category? first = all
        .where((Category c) => _categoryIds.contains(c.id))
        .firstOrNull;
    return first == null
        ? l10n.quickSaveSaved
        : l10n.quickSaveSavedIn(first.name);
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final List<Category> categories =
        ref.watch(categoriesProvider).asData?.value ?? const <Category>[];

    return ConstrainedBox(
      // Sin un techo de altura el Flexible no tiene contra qué encoger y la
      // hoja crece más allá de la pantalla, dejando el botón Guardar fuera.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.xl,
          right: Spacing.xl,
          top: Spacing.xl,
          bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.xl,
        ),
        // El botón Guardar queda fijo al fondo y sólo se desplaza el contenido:
        // Quick Save promete "compartir y guardar en un toque", y eso se rompe si
        // en una pantalla pequeña hay que buscar el botón desplazándose.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      l10n.quickSaveTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Spacing.lg),
                    _SharePreview(share: widget.share),

                    if (_error != null) ...<Widget>[
                      const SizedBox(height: Spacing.md),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: Spacing.xl),
                    _FieldLabel(l10n.quickSaveStatus),
                    const SizedBox(height: Spacing.sm),
                    Wrap(
                      spacing: Spacing.sm,
                      children: <Widget>[
                        for (final CardStatus status in CardStatus.values)
                          GestureDetector(
                            onTap: () => setState(() => _status = status),
                            child: Opacity(
                              opacity: _status == status ? 1 : 0.45,
                              child: StatusPill(status: status),
                            ),
                          ),
                      ],
                    ),

                    if (categories.isNotEmpty) ...<Widget>[
                      const SizedBox(height: Spacing.xl),
                      _FieldLabel(l10n.quickSaveCategories),
                      const SizedBox(height: Spacing.sm),
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.sm,
                        children: <Widget>[
                          for (final Category category in categories)
                            FilterChip(
                              label: Text(category.name),
                              selected: _categoryIds.contains(category.id),
                              onSelected: (bool selected) => setState(() {
                                if (selected) {
                                  _categoryIds.add(category.id);
                                } else {
                                  _categoryIds.remove(category.id);
                                }
                              }),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: Spacing.xl),
                    SambaTextField(
                      controller: _note,
                      label: l10n.quickSaveNote,
                      hint: l10n.quickSaveNoteHint,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SambaButton(
                  variant: SambaButtonVariant.ghost,
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  label: l10n.cancel,
                ),
                const SizedBox(width: Spacing.md),
                SambaButton(
                  onPressed: _saving ? null : () => unawaited(_save()),
                  label: l10n.save,
                  loading: _saving,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }
}

/// Lo que se sabe del enlace antes de guardarlo: la URL canónica, la
/// plataforma y el dominio. La vista previa real llega después de guardar,
/// porque esperar a la red aquí rompería el "capture first".
class _SharePreview extends StatelessWidget {
  const _SharePreview({required this.share});

  final IncomingShare share;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);
    final SambaColors samba = theme.extension<SambaColors>()!;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: samba.surfaceElevated,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            share.normalized?.canonical ?? share.url ?? share.rawText,
            style: theme.textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            share.normalized == null
                ? l10n.quickSavePending
                : '${share.platform.value} · ${share.normalized!.domain}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
