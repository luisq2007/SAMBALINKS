import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart'
    show SambaButton, SambaButtonVariant, SambaTextField;
import '../domain/link_card.dart';
import '../domain/url_extractor.dart';

/// Guardado manual de un enlace.
///
/// Es la variante de escritorio y teclado del flujo "Compartir → Guardar":
/// **ningún campo salvo la URL es obligatorio**. El estado queda en Pendiente y
/// sin categoría, es decir, en la Bandeja. Todo lo demás —notas, categorías,
/// estado— se edita después desde el detalle, que ya existe.
class AddLinkSheet extends ConsumerStatefulWidget {
  const AddLinkSheet({super.key});

  /// Abre la hoja. Devuelve el enlace creado, o `null` si se canceló.
  static Future<LinkCard?> show(BuildContext context) {
    return showModalBottomSheet<LinkCard>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => const AddLinkSheet(),
    );
  }

  @override
  ConsumerState<AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends ConsumerState<AddLinkSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _error;
  bool _saving = false;

  /// Pega la URL del portapapeles, **sólo a petición del usuario**.
  ///
  /// Leerlo al abrir la hoja sería un toque menos, pero Android avisa con un
  /// mensaje del sistema cada vez que una app lee el portapapeles. Aparecer
  /// como una app que fisgonea el portapapeles al abrirse contradice el
  /// principio "Privacy First" del producto por ahorrar un toque.
  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? url = extractFirstUrl(data?.text ?? '');
    if (!mounted) {
      return;
    }
    setState(() {
      _error = url == null ? L10n.of(context).addLinkInvalid : null;
      if (url != null) {
        _controller.text = url;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final L10n l10n = L10n.of(context);
    setState(() {
      _error = null;
      _saving = true;
    });

    // Mismo camino que Quick Save: normalizar, deduplicar, guardar y pedir
    // metadata sin bloquear. Que ambas rutas compartan esto es lo que evita
    // que se comporten distinto ante un duplicado.
    final Result<LinkCard> result = await ref
        .read(linkSaverProvider)
        .save(rawUrl: _controller.text);

    if (!mounted) {
      return;
    }

    await result.fold(
      onSuccess: (LinkCard saved) async {
        Navigator.of(context).pop(saved);
      },
      onFailure: (AppFailure failure) async {
        if (failure is DuplicateLinkFailure) {
          await _reportDuplicate(failure.existingCardId);
        } else {
          setState(() {
            _saving = false;
            _error = failure is InvalidUrlFailure
                ? l10n.addLinkInvalid
                : l10n.addLinkSaveError;
          });
        }
      },
    );
  }

  /// §27 del PRD: por defecto no se duplica. Se avisa y se ofrece abrir el que
  /// ya existe, en lugar de crear una copia en silencio.
  Future<void> _reportDuplicate(String existingId) async {
    final L10n l10n = L10n.of(context);
    final LinkCard? existing = await ref
        .read(linkRepositoryProvider)
        .findById(existingId);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    final String when = existing == null
        ? ''
        : DateFormat.yMMMMd('es').format(existing.createdAt.toLocal());

    final bool open =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(l10n.addLinkDuplicateTitle),
            content: Text(l10n.addLinkDuplicateBody(when)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.addLinkOpenExisting),
              ),
            ],
          ),
        ) ??
        false;

    if (open && existing != null && mounted) {
      Navigator.of(context).pop(existing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.xl,
        right: Spacing.xl,
        top: Spacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.addLinkTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Spacing.xl),
          SambaTextField(
            controller: _controller,
            focusNode: _focusNode,
            label: l10n.addLinkField,
            hint: l10n.addLinkHint,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            errorText: _error,
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (_) => unawaited(_save()),
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: SambaButton(
              variant: SambaButtonVariant.ghost,
              icon: Icons.content_paste_outlined,
              onPressed: _saving
                  ? null
                  : () => unawaited(_pasteFromClipboard()),
              label: l10n.addLinkFromClipboard,
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
    );
  }
}
