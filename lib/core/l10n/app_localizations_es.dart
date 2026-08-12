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
}
