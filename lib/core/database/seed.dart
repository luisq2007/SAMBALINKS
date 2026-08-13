import '../../features/categories/domain/category_repository.dart';
import 'daos/settings_dao.dart';

/// Categorías de ejemplo del primer arranque.
///
/// Una biblioteca vacía sin ninguna categoría obliga al usuario a inventarse
/// una taxonomía antes de haber guardado nada. Estas tres son suficientemente
/// genéricas para servir de ejemplo y se pueden borrar.
const List<({String name, String color, String icon})> seedCategories =
    <({String name, String color, String icon})>[
      (name: 'Leer después', color: '#B9ECFA', icon: 'bookmark'),
      (name: 'Inspiración', color: '#B9F7D8', icon: 'lightbulb'),
      (name: 'Ideas', color: '#FFF0BD', icon: 'sparkles'),
    ];

/// Crea las categorías de ejemplo una única vez.
///
/// La marca vive en `settings` y no en "¿hay categorías?": si el usuario borra
/// todas las suyas, no queremos que reaparezcan las de ejemplo.
Future<void> seedIfNeeded({
  required CategoryRepository categories,
  required SettingsDao settings,
}) async {
  final bool? done = await settings.read<bool>(SettingsKeys.seedCompleted);
  if (done ?? false) {
    return;
  }

  for (final ({String color, String icon, String name}) entry
      in seedCategories) {
    await categories.create(
      name: entry.name,
      color: entry.color,
      icon: entry.icon,
    );
  }

  await settings.write(SettingsKeys.seedCompleted, true);
}
