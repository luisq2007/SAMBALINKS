import 'package:flutter/material.dart';

class CategoryIconChoice {
  const CategoryIconChoice(this.key, this.icon);

  final String key;
  final IconData icon;
}

abstract final class CategoryIconCatalog {
  static const List<CategoryIconChoice> choices = <CategoryIconChoice>[
    CategoryIconChoice('folder', Icons.folder_outlined),
    CategoryIconChoice('lightbulb', Icons.lightbulb_outline),
    CategoryIconChoice('bookmark', Icons.bookmark_outline),
    CategoryIconChoice('work', Icons.work_outline),
    CategoryIconChoice('favorite', Icons.favorite_outline),
    CategoryIconChoice('code', Icons.code),
    CategoryIconChoice('travel', Icons.flight_outlined),
    CategoryIconChoice('school', Icons.school_outlined),
  ];

  static IconData fromKey(String? key) =>
      choices
          .where((CategoryIconChoice choice) => choice.key == key)
          .firstOrNull
          ?.icon ??
      Icons.folder_outlined;
}
