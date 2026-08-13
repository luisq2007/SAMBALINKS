import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Raíz de la aplicación.
class SambaLinksApp extends StatefulWidget {
  const SambaLinksApp({this.initialRoute = '/', super.key});

  final String initialRoute;

  @override
  State<SambaLinksApp> createState() => _SambaLinksAppState();
}

class _SambaLinksAppState extends State<SambaLinksApp> {
  // Provisional: en la Fase 14 pasa a persistirse en la tabla `settings`.
  ThemeMode _themeMode = ThemeMode.system;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      initialLocation: widget.initialRoute,
      onToggleTheme: _toggleTheme,
    );
  }

  void _toggleTheme(Brightness effective) {
    setState(() {
      _themeMode = effective == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => L10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('es'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
