import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Acciones que dispara un atajo de teclado.
class AppShortcutActions {
  const AppShortcutActions({
    required this.onSearch,
    required this.onAddLink,
    required this.onFilters,
  });

  final VoidCallback onSearch;
  final VoidCallback onAddLink;
  final VoidCallback onFilters;
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _AddLinkIntent extends Intent {
  const _AddLinkIntent();
}

class _FiltersIntent extends Intent {
  const _FiltersIntent();
}

/// Atajos de teclado del escritorio (§40 del PRD).
///
/// **`CMD/CTRL + F` busca**, no filtra, al contrario de lo que decía §40: en
/// cualquier aplicación de escritorio esa combinación es buscar, y romper esa
/// expectativa se paga en cada uso. Los filtros van a `CMD/CTRL + SHIFT + F`.
/// La decisión quedó cerrada en §4.5 del plan.
///
/// `ESC` no se declara aquí: cerrar una hoja o un diálogo ya lo gestiona
/// Flutter con el comportamiento estándar de la plataforma.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({required this.actions, required this.child, super.key});

  final AppShortcutActions actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      // meta para macOS, control para Windows y Linux: el mismo binario corre
      // en los tres, así que se declaran ambos.
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, meta: true): _SearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _SearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, meta: true): _SearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _SearchIntent(),

        SingleActivator(LogicalKeyboardKey.keyN, meta: true): _AddLinkIntent(),
        SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _AddLinkIntent(),

        SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true):
            _FiltersIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: true, shift: true):
            _FiltersIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SearchIntent: CallbackAction<_SearchIntent>(
            onInvoke: (_) {
              actions.onSearch();
              return null;
            },
          ),
          _AddLinkIntent: CallbackAction<_AddLinkIntent>(
            onInvoke: (_) {
              actions.onAddLink();
              return null;
            },
          ),
          _FiltersIntent: CallbackAction<_FiltersIntent>(
            onInvoke: (_) {
              actions.onFilters();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
