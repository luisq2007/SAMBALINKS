// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SambaLinks';

  @override
  String get appTagline => 'Tu bandeja personal para Internet';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusDone => 'Atendido';

  @override
  String get navHome => 'Inicio';

  @override
  String get navKanban => 'Kanban';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navigationCollapse => 'Contraer navegación';

  @override
  String get navigationExpand => 'Expandir navegación';

  @override
  String navigationDestinationCount(String label, int count) {
    return '$label, $count enlaces';
  }

  @override
  String get wideDetailTitle => 'Detalle del enlace';

  @override
  String get wideDetailBody =>
      'Selecciona un enlace para ver y editar sus detalles sin salir de la lista.';

  @override
  String get kanbanEmptyTitle => 'Organiza tu flujo';

  @override
  String get kanbanEmptyBody =>
      'Tus enlaces aparecerán en columnas según su estado.';

  @override
  String get categoriesEmptyTitle => 'Organiza por categorías';

  @override
  String get categoriesEmptyBody =>
      'Crea categorías para encontrar tus enlaces por tema o proyecto.';

  @override
  String get settingsPlaceholderTitle => 'Configura SambaLinks';

  @override
  String get settingsPlaceholderBody =>
      'Personaliza la apariencia y administra los datos de tu biblioteca.';

  @override
  String get inbox => 'Bandeja';

  @override
  String get allLinks => 'Todos los enlaces';

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get link => 'Enlace';

  @override
  String get links => 'Enlaces';

  @override
  String get category => 'Categoría';

  @override
  String get categories => 'Categorías';

  @override
  String get note => 'Nota';

  @override
  String get notes => 'Notas';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar en SambaLinks…';

  @override
  String get filters => 'Filtros';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortOldest => 'Más antiguos';

  @override
  String get sortRecentlyUpdated => 'Actualizados recientemente';

  @override
  String get sortTitleAsc => 'Título A-Z';

  @override
  String get sortTitleDesc => 'Título Z-A';

  @override
  String get sortPlatform => 'Plataforma';

  @override
  String get sortStatus => 'Estado';

  @override
  String get sortMenuTooltip => 'Cambiar orden';

  @override
  String get viewCompact => 'Vista compacta';

  @override
  String get viewComfortable => 'Vista cómoda';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get loadingLinks => 'Cargando enlaces';

  @override
  String get linksLoadErrorTitle => 'No pudimos cargar tus enlaces';

  @override
  String get linksLoadErrorBody =>
      'Tu biblioteca sigue guardada. Intenta cargarla de nuevo.';

  @override
  String get libraryEmptyTitle => 'Tu biblioteca está vacía';

  @override
  String get libraryEmptyBody =>
      'Guarda tu primer enlace para empezar a construir una biblioteca personal.';

  @override
  String get filterEmptyTitle => 'Ningún enlace coincide con estos filtros';

  @override
  String get filterEmptyBody =>
      'Prueba otra combinación o limpia los filtros para ver toda tu biblioteca.';

  @override
  String searchEmptyTitle(String query) {
    return 'No encontramos “$query”';
  }

  @override
  String get searchEmptyBody =>
      'Prueba con otro título, dominio, nota, categoría o plataforma.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enlaces',
      one: '1 enlace',
      zero: 'Sin enlaces',
    );
    return '$_temp0';
  }

  @override
  String filterActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtros activos',
      one: '1 filtro activo',
    );
    return '$_temp0';
  }

  @override
  String get filterSheetTitle => 'Filtrar enlaces';

  @override
  String get filterApply => 'Aplicar filtros';

  @override
  String get filterStatus => 'Estado';

  @override
  String get filterPlatform => 'Plataforma';

  @override
  String get filterCategory => 'Categoría';

  @override
  String get filterDate => 'Fecha guardada';

  @override
  String get filterPreview => 'Vista previa';

  @override
  String get filterNotes => 'Notas';

  @override
  String get filterAny => 'Cualquiera';

  @override
  String get filterWithImage => 'Con imagen';

  @override
  String get filterWithoutImage => 'Sin imagen';

  @override
  String get filterWithNotes => 'Con notas';

  @override
  String get filterWithoutNotes => 'Sin notas';

  @override
  String get filterUncategorized => 'Sólo sin categoría';

  @override
  String get filterDateAny => 'Cualquier fecha';

  @override
  String get filterDateToday => 'Hoy';

  @override
  String get filterDateLast7Days => 'Últimos 7 días';

  @override
  String get filterDateLast30Days => 'Últimos 30 días';

  @override
  String get platformInstagram => 'Instagram';

  @override
  String get platformX => 'X';

  @override
  String get platformThreads => 'Threads';

  @override
  String get platformPinterest => 'Pinterest';

  @override
  String get platformFacebook => 'Facebook';

  @override
  String get platformTikTok => 'TikTok';

  @override
  String get platformYouTube => 'YouTube';

  @override
  String get platformLinkedIn => 'LinkedIn';

  @override
  String get platformReddit => 'Reddit';

  @override
  String get platformWeb => 'Web';

  @override
  String get platformOther => 'Otro';

  @override
  String cardImageSemantics(String title) {
    return 'Vista previa de $title';
  }

  @override
  String cardSelectSemantics(String title) {
    return 'Seleccionar $title';
  }

  @override
  String get cardNotesAvailable => 'Tiene notas';

  @override
  String get cardNoPreview => 'Sin imagen';

  @override
  String get incomingLinkReceived => 'Enlace recibido';

  @override
  String get dismiss => 'Descartar';

  @override
  String selectedLinksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enlaces seleccionados',
      one: '1 enlace seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get clearSelection => 'Cancelar selección';

  @override
  String get detailTitleField => 'Título';

  @override
  String get detailDescriptionField => 'Descripción';

  @override
  String get detailNotesField => 'Notas';

  @override
  String get detailSaving => 'Guardando cambios…';

  @override
  String get detailSaved => 'Cambios guardados';

  @override
  String get detailSaveError => 'No pudimos guardar los cambios';

  @override
  String get detailRefreshSuccess => 'Vista previa actualizada';

  @override
  String get detailRefreshError =>
      'No pudimos actualizar la vista previa. El enlace sigue guardado.';

  @override
  String get detailDeleteConfirmTitle => '¿Eliminar este enlace?';

  @override
  String get detailDeleteConfirmBody =>
      'Se quitará de tu biblioteca y de todas sus categorías.';

  @override
  String get detailDeleted => 'Enlace eliminado';

  @override
  String get detailMoreActions => 'Más acciones del enlace';

  @override
  String get detailChangeStatus => 'Cambiar estado';

  @override
  String get detailManageCategories => 'Administrar categorías';

  @override
  String get detailEdit => 'Editar contenido';

  @override
  String get copyAsMarkdown => 'Copiar como Markdown';

  @override
  String get urlCopied => 'URL copiada';

  @override
  String get markdownCopied => 'Enlace copiado como Markdown';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get metadataRefreshing => 'Actualizando vista previa…';

  @override
  String get confirm => 'Confirmar';

  @override
  String get openOriginalError => 'No pudimos abrir el enlace original.';

  @override
  String get categoriesApply => 'Guardar categorías';

  @override
  String get categoryNew => 'Nueva categoría';

  @override
  String get categoryEdit => 'Editar categoría';

  @override
  String get categoryName => 'Nombre';

  @override
  String get categoryNameHint => 'Ej. Ideas';

  @override
  String get categoryNameRequired => 'Escribe un nombre para la categoría';

  @override
  String get categoryDuplicate => 'Ya existe una categoría con ese nombre';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryIcon => 'Icono';

  @override
  String categoryColorOption(int number) {
    return 'Color $number';
  }

  @override
  String categoryIconOption(int number) {
    return 'Icono $number';
  }

  @override
  String categoryActions(String name) {
    return 'Acciones de $name';
  }

  @override
  String categoryOpen(String name) {
    return 'Abrir categoría $name';
  }

  @override
  String categoryLinkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enlaces',
      one: '1 enlace',
      zero: 'Sin enlaces',
    );
    return '$_temp0';
  }

  @override
  String categoryReorder(String name) {
    return 'Reordenar $name';
  }

  @override
  String categoryDeleteTitle(String name) {
    return '¿Eliminar “$name”?';
  }

  @override
  String get categoryDeleteBody =>
      'Los enlaces no se eliminarán. Sólo perderán esta categoría y quedarán en la Bandeja si no tienen otra.';

  @override
  String get categoryDeleted =>
      'Categoría eliminada; tus enlaces siguen guardados';

  @override
  String get categorySaveError => 'No pudimos guardar la categoría';

  @override
  String get categoryLoadError => 'No pudimos cargar tus categorías';

  @override
  String get categoryCreateFirst => 'Crear primera categoría';

  @override
  String get categoryBack => 'Volver a categorías';

  @override
  String get categoryMissingTitle => 'Esta categoría ya no existe';

  @override
  String get categoryMissingBody =>
      'Puede que haya sido eliminada en otra ventana.';

  @override
  String get inboxDescription => 'Enlaces que todavía no tienen categoría';

  @override
  String get scopeClose => 'Cerrar esta vista';

  @override
  String get add => 'Añadir';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get undo => 'Deshacer';

  @override
  String get openOriginal => 'Abrir original';

  @override
  String get copyUrl => 'Copiar URL';

  @override
  String get share => 'Compartir';

  @override
  String get refreshPreview => 'Actualizar vista previa';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsData => 'Datos';

  @override
  String get exportLibrary => 'Exportar biblioteca';

  @override
  String get importLibrary => 'Importar biblioteca';

  @override
  String get importMerge => 'Combinar';

  @override
  String get importReplace => 'Reemplazar';

  @override
  String get previewUnavailableTitle => 'Vista previa no disponible';

  @override
  String get previewUnavailableBody =>
      'Guardamos tu enlace, pero no pudimos recuperar su vista previa.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get inboxEmptyTitle => 'Tu bandeja está vacía';

  @override
  String get inboxEmptyBody =>
      'Comparte un enlace desde Instagram, X, Threads, Pinterest o cualquier sitio web y aparecerá aquí.';

  @override
  String get addFirstLink => 'Añadir tu primer enlace';

  @override
  String get shareArrivalCold => 'app cerrada';

  @override
  String get shareArrivalWarm => 'app en segundo plano';

  @override
  String get shareMissingUrl => 'Sin URL en el texto compartido';

  @override
  String get shortLink => 'acortado';

  @override
  String get devGalleryTitle => 'Galería de componentes';

  @override
  String get devGalleryThemeTooltip => 'Cambiar tema';

  @override
  String get devGalleryButtons => 'Botones';

  @override
  String get devGalleryFields => 'Campos de texto';

  @override
  String get devGalleryStatuses => 'Estados';

  @override
  String get devGalleryCategories => 'Categorías';

  @override
  String get devGalleryCards => 'Tarjetas';

  @override
  String get devGalleryEmptyStates => 'Estados vacíos';

  @override
  String get devGalleryOverlays => 'Paneles y menús';

  @override
  String get devGalleryLoading => 'Cargando';

  @override
  String get devGallerySecondaryAction => 'Acción secundaria';

  @override
  String get devGalleryGhostAction => 'Acción discreta';

  @override
  String get devGalleryDeleteAction => 'Eliminar enlace';

  @override
  String get devGalleryTitleField => 'Título del enlace';

  @override
  String get devGalleryTitleHint => 'Una lectura para después';

  @override
  String get devGalleryNotesField => 'Notas opcionales';

  @override
  String get devGalleryNotesHint =>
      'Añade contexto para recordar por qué lo guardaste';

  @override
  String get devGallerySampleCardTitle =>
      'Diseñar productos que se sienten simples';

  @override
  String get devGallerySampleCardBody =>
      'Un ejemplo de tarjeta interactiva con estado, categoría y acciones.';

  @override
  String get devGallerySampleDomain => 'ejemplo.com';

  @override
  String get devGalleryCategoryReadLater => 'Leer después';

  @override
  String get devGalleryCategoryInspiration => 'Inspiración';

  @override
  String get devGalleryEmptyTitle => 'Todavía no hay enlaces aquí';

  @override
  String get devGalleryEmptyBody =>
      'Cuando guardes un enlace aparecerá en este espacio.';

  @override
  String get devGalleryOpenSheet => 'Abrir panel';

  @override
  String get devGallerySheetTitle => 'Editar enlace';

  @override
  String get devGallerySheetBody =>
      'Los paneles mantienen el contexto y dejan las acciones principales al alcance.';

  @override
  String get devGalleryMenuTooltip => 'Más acciones';

  @override
  String get addLinkTitle => 'Guardar en SambaLinks';

  @override
  String get addLinkField => 'URL del enlace';

  @override
  String get addLinkHint => 'https://…';

  @override
  String get addLinkFromClipboard => 'Pegar del portapapeles';

  @override
  String get addLinkInvalid => 'Eso no parece un enlace válido';

  @override
  String get addLinkSaved => 'Enlace guardado en la Bandeja';

  @override
  String get addLinkSaveError => 'No pudimos guardar el enlace';

  @override
  String get addLinkDuplicateTitle => 'Este enlace ya está en SambaLinks';

  @override
  String addLinkDuplicateBody(String date) {
    return 'Lo guardaste el $date.';
  }

  @override
  String get addLinkOpenExisting => 'Abrir el que ya tienes';
}
