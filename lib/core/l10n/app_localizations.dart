import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre del producto. No se traduce.
  ///
  /// In es, this message translates to:
  /// **'SambaLinks'**
  String get appName;

  /// Descripción corta mostrada en Ajustes y en el estado vacío inicial.
  ///
  /// In es, this message translates to:
  /// **'Tu bandeja personal para Internet'**
  String get appTagline;

  /// Estado interno: pending. Contenido guardado pero aún sin procesar.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// Estado interno: active. Contenido en uso o en investigación.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get statusActive;

  /// Estado interno: done. Contenido ya revisado.
  ///
  /// In es, this message translates to:
  /// **'Atendido'**
  String get statusDone;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navKanban.
  ///
  /// In es, this message translates to:
  /// **'Kanban'**
  String get navKanban;

  /// No description provided for @navCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get navCategories;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Enlaces sin categoría asignada. Es una consulta, no una categoría real.
  ///
  /// In es, this message translates to:
  /// **'Bandeja'**
  String get inbox;

  /// No description provided for @allLinks.
  ///
  /// In es, this message translates to:
  /// **'Todos los enlaces'**
  String get allLinks;

  /// No description provided for @uncategorized.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get uncategorized;

  /// No description provided for @link.
  ///
  /// In es, this message translates to:
  /// **'Enlace'**
  String get link;

  /// No description provided for @links.
  ///
  /// In es, this message translates to:
  /// **'Enlaces'**
  String get links;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categories;

  /// No description provided for @note.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get note;

  /// No description provided for @notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notes;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar en SambaLinks…'**
  String get searchHint;

  /// No description provided for @filters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// No description provided for @sort.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// No description provided for @sortNewest.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In es, this message translates to:
  /// **'Más antiguos'**
  String get sortOldest;

  /// No description provided for @sortRecentlyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizados recientemente'**
  String get sortRecentlyUpdated;

  /// No description provided for @sortTitleAsc.
  ///
  /// In es, this message translates to:
  /// **'Título A-Z'**
  String get sortTitleAsc;

  /// No description provided for @sortTitleDesc.
  ///
  /// In es, this message translates to:
  /// **'Título Z-A'**
  String get sortTitleDesc;

  /// No description provided for @sortPlatform.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get sortPlatform;

  /// No description provided for @sortStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get sortStatus;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @undo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// No description provided for @openOriginal.
  ///
  /// In es, this message translates to:
  /// **'Abrir original'**
  String get openOriginal;

  /// No description provided for @copyUrl.
  ///
  /// In es, this message translates to:
  /// **'Copiar URL'**
  String get copyUrl;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// Vuelve a consultar la URL. Nunca toca categorías, estado ni notas.
  ///
  /// In es, this message translates to:
  /// **'Actualizar vista previa'**
  String get refreshPreview;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @settingsData.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get settingsData;

  /// No description provided for @exportLibrary.
  ///
  /// In es, this message translates to:
  /// **'Exportar biblioteca'**
  String get exportLibrary;

  /// No description provided for @importLibrary.
  ///
  /// In es, this message translates to:
  /// **'Importar biblioteca'**
  String get importLibrary;

  /// No description provided for @importMerge.
  ///
  /// In es, this message translates to:
  /// **'Combinar'**
  String get importMerge;

  /// No description provided for @importReplace.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get importReplace;

  /// No description provided for @previewUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista previa no disponible'**
  String get previewUnavailableTitle;

  /// No description provided for @previewUnavailableBody.
  ///
  /// In es, this message translates to:
  /// **'Guardamos tu enlace, pero no pudimos recuperar su vista previa.'**
  String get previewUnavailableBody;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get tryAgain;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu bandeja está vacía'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Comparte un enlace desde Instagram, X, Threads, Pinterest o cualquier sitio web y aparecerá aquí.'**
  String get inboxEmptyBody;

  /// No description provided for @addFirstLink.
  ///
  /// In es, this message translates to:
  /// **'Añadir tu primer enlace'**
  String get addFirstLink;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return L10nEs();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
