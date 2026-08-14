import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/app_localizations.dart';
import 'core/providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Raíz de la aplicación.
class SambaLinksApp extends ConsumerStatefulWidget {
  const SambaLinksApp({this.initialRoute = '/', super.key});

  final String initialRoute;

  @override
  ConsumerState<SambaLinksApp> createState() => _SambaLinksAppState();
}

class _SambaLinksAppState extends ConsumerState<SambaLinksApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      initialLocation: widget.initialRoute,
      onToggleTheme: _toggleTheme,
    );
  }

  /// El botón de la barra superior alterna claro y oscuro de forma explícita.
  /// Para volver a "Sistema" está el selector de Ajustes.
  void _toggleTheme(Brightness effective) {
    ref
        .read(themeModeProvider.notifier)
        .setMode(
          effective == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
        );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se lee la preferencia se usa Sistema, que es el valor por
    // defecto: así no hay un parpadeo de tema en el arranque.
    final ThemeMode mode =
        ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => L10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('es'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
