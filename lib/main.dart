import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  const bool showGallery = bool.fromEnvironment('SAMBA_DEV_GALLERY');
  runApp(
    const ProviderScope(
      child: SambaLinksApp(initialRoute: showGallery ? '/dev/gallery' : '/'),
    ),
  );
}
