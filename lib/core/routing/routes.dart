abstract final class AppRoutes {
  static const String home = '/';
  static const String kanban = '/kanban';
  static const String categories = '/categories';
  static const String inbox = '/inbox';
  static const String settings = '/settings';
  static const String gallery = '/dev/gallery';
  static const String shareSpike = '/dev/share';

  static String category(String id) => '$categories/$id';
}
