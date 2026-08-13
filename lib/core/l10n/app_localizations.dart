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

  /// No description provided for @navigationCollapse.
  ///
  /// In es, this message translates to:
  /// **'Contraer navegación'**
  String get navigationCollapse;

  /// No description provided for @navigationExpand.
  ///
  /// In es, this message translates to:
  /// **'Expandir navegación'**
  String get navigationExpand;

  /// No description provided for @navigationDestinationCount.
  ///
  /// In es, this message translates to:
  /// **'{label}, {count} enlaces'**
  String navigationDestinationCount(String label, int count);

  /// No description provided for @wideDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del enlace'**
  String get wideDetailTitle;

  /// No description provided for @wideDetailBody.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un enlace para ver y editar sus detalles sin salir de la lista.'**
  String get wideDetailBody;

  /// No description provided for @kanbanEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza tu flujo'**
  String get kanbanEmptyTitle;

  /// No description provided for @kanbanEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Tus enlaces aparecerán en columnas según su estado.'**
  String get kanbanEmptyBody;

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza por categorías'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Crea categorías para encontrar tus enlaces por tema o proyecto.'**
  String get categoriesEmptyBody;

  /// No description provided for @settingsPlaceholderTitle.
  ///
  /// In es, this message translates to:
  /// **'Configura SambaLinks'**
  String get settingsPlaceholderTitle;

  /// No description provided for @settingsPlaceholderBody.
  ///
  /// In es, this message translates to:
  /// **'Personaliza la apariencia y administra los datos de tu biblioteca.'**
  String get settingsPlaceholderBody;

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

  /// No description provided for @sortMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar orden'**
  String get sortMenuTooltip;

  /// No description provided for @viewCompact.
  ///
  /// In es, this message translates to:
  /// **'Vista compacta'**
  String get viewCompact;

  /// No description provided for @viewComfortable.
  ///
  /// In es, this message translates to:
  /// **'Vista cómoda'**
  String get viewComfortable;

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get loadMore;

  /// No description provided for @loadingLinks.
  ///
  /// In es, this message translates to:
  /// **'Cargando enlaces'**
  String get loadingLinks;

  /// No description provided for @linksLoadErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus enlaces'**
  String get linksLoadErrorTitle;

  /// No description provided for @linksLoadErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca sigue guardada. Intenta cargarla de nuevo.'**
  String get linksLoadErrorBody;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca está vacía'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Guarda tu primer enlace para empezar a construir una biblioteca personal.'**
  String get libraryEmptyBody;

  /// No description provided for @filterEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Ningún enlace coincide con estos filtros'**
  String get filterEmptyTitle;

  /// No description provided for @filterEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Prueba otra combinación o limpia los filtros para ver toda tu biblioteca.'**
  String get filterEmptyBody;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos “{query}”'**
  String searchEmptyTitle(String query);

  /// No description provided for @searchEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro título, dominio, nota, categoría o plataforma.'**
  String get searchEmptyBody;

  /// No description provided for @resultCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin enlaces} =1{1 enlace} other{{count} enlaces}}'**
  String resultCount(int count);

  /// No description provided for @filterActiveCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 filtro activo} other{{count} filtros activos}}'**
  String filterActiveCount(int count);

  /// No description provided for @filterSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar enlaces'**
  String get filterSheetTitle;

  /// No description provided for @filterApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get filterApply;

  /// No description provided for @filterStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get filterStatus;

  /// No description provided for @filterPlatform.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get filterPlatform;

  /// No description provided for @filterCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get filterCategory;

  /// No description provided for @filterDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha guardada'**
  String get filterDate;

  /// No description provided for @filterPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get filterPreview;

  /// No description provided for @filterNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get filterNotes;

  /// No description provided for @filterAny.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get filterAny;

  /// No description provided for @filterWithImage.
  ///
  /// In es, this message translates to:
  /// **'Con imagen'**
  String get filterWithImage;

  /// No description provided for @filterWithoutImage.
  ///
  /// In es, this message translates to:
  /// **'Sin imagen'**
  String get filterWithoutImage;

  /// No description provided for @filterWithNotes.
  ///
  /// In es, this message translates to:
  /// **'Con notas'**
  String get filterWithNotes;

  /// No description provided for @filterWithoutNotes.
  ///
  /// In es, this message translates to:
  /// **'Sin notas'**
  String get filterWithoutNotes;

  /// No description provided for @filterUncategorized.
  ///
  /// In es, this message translates to:
  /// **'Sólo sin categoría'**
  String get filterUncategorized;

  /// No description provided for @filterDateAny.
  ///
  /// In es, this message translates to:
  /// **'Cualquier fecha'**
  String get filterDateAny;

  /// No description provided for @filterDateToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get filterDateToday;

  /// No description provided for @filterDateLast7Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get filterDateLast7Days;

  /// No description provided for @filterDateLast30Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get filterDateLast30Days;

  /// No description provided for @platformInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram'**
  String get platformInstagram;

  /// No description provided for @platformX.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get platformX;

  /// No description provided for @platformThreads.
  ///
  /// In es, this message translates to:
  /// **'Threads'**
  String get platformThreads;

  /// No description provided for @platformPinterest.
  ///
  /// In es, this message translates to:
  /// **'Pinterest'**
  String get platformPinterest;

  /// No description provided for @platformFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook'**
  String get platformFacebook;

  /// No description provided for @platformTikTok.
  ///
  /// In es, this message translates to:
  /// **'TikTok'**
  String get platformTikTok;

  /// No description provided for @platformYouTube.
  ///
  /// In es, this message translates to:
  /// **'YouTube'**
  String get platformYouTube;

  /// No description provided for @platformLinkedIn.
  ///
  /// In es, this message translates to:
  /// **'LinkedIn'**
  String get platformLinkedIn;

  /// No description provided for @platformReddit.
  ///
  /// In es, this message translates to:
  /// **'Reddit'**
  String get platformReddit;

  /// No description provided for @platformWeb.
  ///
  /// In es, this message translates to:
  /// **'Web'**
  String get platformWeb;

  /// No description provided for @platformOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get platformOther;

  /// No description provided for @cardImageSemantics.
  ///
  /// In es, this message translates to:
  /// **'Vista previa de {title}'**
  String cardImageSemantics(String title);

  /// No description provided for @cardSelectSemantics.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar {title}'**
  String cardSelectSemantics(String title);

  /// No description provided for @cardNotesAvailable.
  ///
  /// In es, this message translates to:
  /// **'Tiene notas'**
  String get cardNotesAvailable;

  /// No description provided for @cardNoPreview.
  ///
  /// In es, this message translates to:
  /// **'Sin imagen'**
  String get cardNoPreview;

  /// No description provided for @incomingLinkReceived.
  ///
  /// In es, this message translates to:
  /// **'Enlace recibido'**
  String get incomingLinkReceived;

  /// No description provided for @dismiss.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get dismiss;

  /// No description provided for @selectedLinksCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 enlace seleccionado} other{{count} enlaces seleccionados}}'**
  String selectedLinksCount(int count);

  /// No description provided for @clearSelection.
  ///
  /// In es, this message translates to:
  /// **'Cancelar selección'**
  String get clearSelection;

  /// No description provided for @detailTitleField.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get detailTitleField;

  /// No description provided for @detailDescriptionField.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get detailDescriptionField;

  /// No description provided for @detailNotesField.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get detailNotesField;

  /// No description provided for @detailSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando cambios…'**
  String get detailSaving;

  /// No description provided for @detailSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get detailSaved;

  /// No description provided for @detailSaveError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar los cambios'**
  String get detailSaveError;

  /// No description provided for @detailRefreshSuccess.
  ///
  /// In es, this message translates to:
  /// **'Vista previa actualizada'**
  String get detailRefreshSuccess;

  /// No description provided for @detailRefreshError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar la vista previa. El enlace sigue guardado.'**
  String get detailRefreshError;

  /// No description provided for @detailDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este enlace?'**
  String get detailDeleteConfirmTitle;

  /// No description provided for @detailDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se quitará de tu biblioteca y de todas sus categorías.'**
  String get detailDeleteConfirmBody;

  /// No description provided for @detailDeleted.
  ///
  /// In es, this message translates to:
  /// **'Enlace eliminado'**
  String get detailDeleted;

  /// No description provided for @detailMoreActions.
  ///
  /// In es, this message translates to:
  /// **'Más acciones del enlace'**
  String get detailMoreActions;

  /// No description provided for @detailChangeStatus.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get detailChangeStatus;

  /// No description provided for @detailManageCategories.
  ///
  /// In es, this message translates to:
  /// **'Administrar categorías'**
  String get detailManageCategories;

  /// No description provided for @detailEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar contenido'**
  String get detailEdit;

  /// No description provided for @copyAsMarkdown.
  ///
  /// In es, this message translates to:
  /// **'Copiar como Markdown'**
  String get copyAsMarkdown;

  /// No description provided for @urlCopied.
  ///
  /// In es, this message translates to:
  /// **'URL copiada'**
  String get urlCopied;

  /// No description provided for @markdownCopied.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado como Markdown'**
  String get markdownCopied;

  /// No description provided for @shareLink.
  ///
  /// In es, this message translates to:
  /// **'Compartir enlace'**
  String get shareLink;

  /// No description provided for @metadataRefreshing.
  ///
  /// In es, this message translates to:
  /// **'Actualizando vista previa…'**
  String get metadataRefreshing;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @openOriginalError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace original.'**
  String get openOriginalError;

  /// No description provided for @categoriesApply.
  ///
  /// In es, this message translates to:
  /// **'Guardar categorías'**
  String get categoriesApply;

  /// No description provided for @categoryNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get categoryNew;

  /// No description provided for @categoryEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get categoryEdit;

  /// No description provided for @categoryName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Ideas'**
  String get categoryNameHint;

  /// No description provided for @categoryNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre para la categoría'**
  String get categoryNameRequired;

  /// No description provided for @categoryDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una categoría con ese nombre'**
  String get categoryDuplicate;

  /// No description provided for @categoryColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @categoryIcon.
  ///
  /// In es, this message translates to:
  /// **'Icono'**
  String get categoryIcon;

  /// No description provided for @categoryColorOption.
  ///
  /// In es, this message translates to:
  /// **'Color {number}'**
  String categoryColorOption(int number);

  /// No description provided for @categoryIconOption.
  ///
  /// In es, this message translates to:
  /// **'Icono {number}'**
  String categoryIconOption(int number);

  /// No description provided for @categoryActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones de {name}'**
  String categoryActions(String name);

  /// No description provided for @categoryOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir categoría {name}'**
  String categoryOpen(String name);

  /// No description provided for @categoryLinkCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin enlaces} =1{1 enlace} other{{count} enlaces}}'**
  String categoryLinkCount(int count);

  /// No description provided for @categoryReorder.
  ///
  /// In es, this message translates to:
  /// **'Reordenar {name}'**
  String categoryReorder(String name);

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar “{name}”?'**
  String categoryDeleteTitle(String name);

  /// No description provided for @categoryDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Los enlaces no se eliminarán. Sólo perderán esta categoría y quedarán en la Bandeja si no tienen otra.'**
  String get categoryDeleteBody;

  /// No description provided for @categoryDeleted.
  ///
  /// In es, this message translates to:
  /// **'Categoría eliminada; tus enlaces siguen guardados'**
  String get categoryDeleted;

  /// No description provided for @categorySaveError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la categoría'**
  String get categorySaveError;

  /// No description provided for @categoryLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus categorías'**
  String get categoryLoadError;

  /// No description provided for @categoryCreateFirst.
  ///
  /// In es, this message translates to:
  /// **'Crear primera categoría'**
  String get categoryCreateFirst;

  /// No description provided for @categoryBack.
  ///
  /// In es, this message translates to:
  /// **'Volver a categorías'**
  String get categoryBack;

  /// No description provided for @categoryMissingTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta categoría ya no existe'**
  String get categoryMissingTitle;

  /// No description provided for @categoryMissingBody.
  ///
  /// In es, this message translates to:
  /// **'Puede que haya sido eliminada en otra ventana.'**
  String get categoryMissingBody;

  /// No description provided for @inboxDescription.
  ///
  /// In es, this message translates to:
  /// **'Enlaces que todavía no tienen categoría'**
  String get inboxDescription;

  /// No description provided for @scopeClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar esta vista'**
  String get scopeClose;

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

  /// No description provided for @shareArrivalCold.
  ///
  /// In es, this message translates to:
  /// **'app cerrada'**
  String get shareArrivalCold;

  /// No description provided for @shareArrivalWarm.
  ///
  /// In es, this message translates to:
  /// **'app en segundo plano'**
  String get shareArrivalWarm;

  /// No description provided for @shareMissingUrl.
  ///
  /// In es, this message translates to:
  /// **'Sin URL en el texto compartido'**
  String get shareMissingUrl;

  /// No description provided for @shortLink.
  ///
  /// In es, this message translates to:
  /// **'acortado'**
  String get shortLink;

  /// No description provided for @devGalleryTitle.
  ///
  /// In es, this message translates to:
  /// **'Galería de componentes'**
  String get devGalleryTitle;

  /// No description provided for @devGalleryThemeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar tema'**
  String get devGalleryThemeTooltip;

  /// No description provided for @devGalleryButtons.
  ///
  /// In es, this message translates to:
  /// **'Botones'**
  String get devGalleryButtons;

  /// No description provided for @devGalleryFields.
  ///
  /// In es, this message translates to:
  /// **'Campos de texto'**
  String get devGalleryFields;

  /// No description provided for @devGalleryStatuses.
  ///
  /// In es, this message translates to:
  /// **'Estados'**
  String get devGalleryStatuses;

  /// No description provided for @devGalleryCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get devGalleryCategories;

  /// No description provided for @devGalleryCards.
  ///
  /// In es, this message translates to:
  /// **'Tarjetas'**
  String get devGalleryCards;

  /// No description provided for @devGalleryEmptyStates.
  ///
  /// In es, this message translates to:
  /// **'Estados vacíos'**
  String get devGalleryEmptyStates;

  /// No description provided for @devGalleryOverlays.
  ///
  /// In es, this message translates to:
  /// **'Paneles y menús'**
  String get devGalleryOverlays;

  /// No description provided for @devGalleryLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get devGalleryLoading;

  /// No description provided for @devGallerySecondaryAction.
  ///
  /// In es, this message translates to:
  /// **'Acción secundaria'**
  String get devGallerySecondaryAction;

  /// No description provided for @devGalleryGhostAction.
  ///
  /// In es, this message translates to:
  /// **'Acción discreta'**
  String get devGalleryGhostAction;

  /// No description provided for @devGalleryDeleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar enlace'**
  String get devGalleryDeleteAction;

  /// No description provided for @devGalleryTitleField.
  ///
  /// In es, this message translates to:
  /// **'Título del enlace'**
  String get devGalleryTitleField;

  /// No description provided for @devGalleryTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Una lectura para después'**
  String get devGalleryTitleHint;

  /// No description provided for @devGalleryNotesField.
  ///
  /// In es, this message translates to:
  /// **'Notas opcionales'**
  String get devGalleryNotesField;

  /// No description provided for @devGalleryNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Añade contexto para recordar por qué lo guardaste'**
  String get devGalleryNotesHint;

  /// No description provided for @devGallerySampleCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Diseñar productos que se sienten simples'**
  String get devGallerySampleCardTitle;

  /// No description provided for @devGallerySampleCardBody.
  ///
  /// In es, this message translates to:
  /// **'Un ejemplo de tarjeta interactiva con estado, categoría y acciones.'**
  String get devGallerySampleCardBody;

  /// No description provided for @devGallerySampleDomain.
  ///
  /// In es, this message translates to:
  /// **'ejemplo.com'**
  String get devGallerySampleDomain;

  /// No description provided for @devGalleryCategoryReadLater.
  ///
  /// In es, this message translates to:
  /// **'Leer después'**
  String get devGalleryCategoryReadLater;

  /// No description provided for @devGalleryCategoryInspiration.
  ///
  /// In es, this message translates to:
  /// **'Inspiración'**
  String get devGalleryCategoryInspiration;

  /// No description provided for @devGalleryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay enlaces aquí'**
  String get devGalleryEmptyTitle;

  /// No description provided for @devGalleryEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando guardes un enlace aparecerá en este espacio.'**
  String get devGalleryEmptyBody;

  /// No description provided for @devGalleryOpenSheet.
  ///
  /// In es, this message translates to:
  /// **'Abrir panel'**
  String get devGalleryOpenSheet;

  /// No description provided for @devGallerySheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar enlace'**
  String get devGallerySheetTitle;

  /// No description provided for @devGallerySheetBody.
  ///
  /// In es, this message translates to:
  /// **'Los paneles mantienen el contexto y dejan las acciones principales al alcance.'**
  String get devGallerySheetBody;

  /// No description provided for @devGalleryMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Más acciones'**
  String get devGalleryMenuTooltip;

  /// Título de la hoja para añadir un enlace a mano.
  ///
  /// In es, this message translates to:
  /// **'Guardar en SambaLinks'**
  String get addLinkTitle;

  /// No description provided for @addLinkField.
  ///
  /// In es, this message translates to:
  /// **'URL del enlace'**
  String get addLinkField;

  /// No description provided for @addLinkHint.
  ///
  /// In es, this message translates to:
  /// **'https://…'**
  String get addLinkHint;

  /// No description provided for @addLinkFromClipboard.
  ///
  /// In es, this message translates to:
  /// **'Pegar del portapapeles'**
  String get addLinkFromClipboard;

  /// No description provided for @addLinkInvalid.
  ///
  /// In es, this message translates to:
  /// **'Eso no parece un enlace válido'**
  String get addLinkInvalid;

  /// No description provided for @addLinkSaved.
  ///
  /// In es, this message translates to:
  /// **'Enlace guardado en la Bandeja'**
  String get addLinkSaved;

  /// No description provided for @addLinkSaveError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el enlace'**
  String get addLinkSaveError;

  /// No description provided for @addLinkDuplicateTitle.
  ///
  /// In es, this message translates to:
  /// **'Este enlace ya está en SambaLinks'**
  String get addLinkDuplicateTitle;

  /// No description provided for @addLinkDuplicateBody.
  ///
  /// In es, this message translates to:
  /// **'Lo guardaste el {date}.'**
  String addLinkDuplicateBody(String date);

  /// No description provided for @addLinkOpenExisting.
  ///
  /// In es, this message translates to:
  /// **'Abrir el que ya tienes'**
  String get addLinkOpenExisting;
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
