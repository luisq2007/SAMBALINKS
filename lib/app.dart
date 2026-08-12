import 'package:flutter/material.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/sharing/presentation/share_spike_screen.dart';

/// Raíz de la aplicación.
///
/// El enrutado llega en la Fase 7; hasta entonces la pantalla del spike de
/// compartir es la única ruta.
class SambaLinksApp extends StatefulWidget {
  const SambaLinksApp({super.key});

  @override
  State<SambaLinksApp> createState() => _SambaLinksAppState();
}

class _SambaLinksAppState extends State<SambaLinksApp> {
  // Provisional: en la Fase 14 pasa a persistirse en la tabla `settings`.
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => L10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('es'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: ShareSpikeScreen(onToggleTheme: _toggleTheme),
    );
  }
}
