import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/network/http_client.dart';
import '../domain/metadata_image_store.dart';

typedef SupportDirectoryResolver = Future<Directory> Function();

class LocalMetadataImageStore implements MetadataImageStore {
  LocalMetadataImageStore(
    this._client, {
    SupportDirectoryResolver? supportDirectory,
  }) : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final SafeHttpClient _client;
  final SupportDirectoryResolver _supportDirectory;

  @override
  Future<String?> persist({
    required String cardId,
    required Uri imageUrl,
  }) async {
    try {
      final SafeHttpResponse response = await _client.get(
        imageUrl,
        maximumBytes: HttpLimits.previewImageBytes,
        headers: const <String, Object>{
          'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final String? extension = _extensionFor(
        response.header('content-type'),
        response.resolvedUri,
      );
      if (extension == null || response.body.isEmpty) {
        return null;
      }

      final Directory support = await _supportDirectory();
      final Directory images = Directory('${support.path}/images');
      await images.create(recursive: true);

      final String safeCardId = cardId.replaceAll(
        RegExp('[^a-zA-Z0-9._-]'),
        '_',
      );
      final String fileName = '$safeCardId.$extension';
      final File destination = File('${images.path}/$fileName');
      final File temporary = File('${destination.path}.tmp');
      await temporary.writeAsBytes(response.body, flush: true);

      await for (final FileSystemEntity entity in images.list()) {
        if (entity is File &&
            entity.path != temporary.path &&
            _baseName(entity.path).startsWith('$safeCardId.')) {
          await entity.delete();
        }
      }
      if (destination.existsSync()) {
        await destination.delete();
      }
      await temporary.rename(destination.path);
      return 'images/$fileName';
    } on Object {
      // Una imagen es complementaria: red, formato o disco lleno no deben
      // convertir una metadata textual válida en un error.
      return null;
    }
  }

  @override
  Future<void> delete(String relativePath) async {
    if (!_isManagedPath(relativePath)) {
      return;
    }
    final Directory support = await _supportDirectory();
    final File file = File('${support.path}/$relativePath');
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<OrphanImageCleanupResult> cleanupOrphans(
    Set<String> referencedPaths, {
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async {
    final Directory support = await _supportDirectory();
    final Directory images = Directory('${support.path}/images');
    if (!images.existsSync()) {
      return const OrphanImageCleanupResult(
        scanned: 0,
        deleted: 0,
        timedOut: false,
      );
    }

    final Stopwatch stopwatch = Stopwatch()..start();
    int scanned = 0;
    int deleted = 0;
    bool timedOut = false;
    await for (final FileSystemEntity entity in images.list()) {
      if (stopwatch.elapsed >= timeLimit) {
        timedOut = true;
        break;
      }
      if (entity is! File) {
        continue;
      }
      scanned += 1;
      final String relative = 'images/${_baseName(entity.path)}';
      if (!referencedPaths.contains(relative)) {
        await entity.delete();
        deleted += 1;
      }
    }

    return OrphanImageCleanupResult(
      scanned: scanned,
      deleted: deleted,
      timedOut: timedOut,
    );
  }

  static String? _extensionFor(String? contentType, Uri uri) {
    final String mime =
        contentType?.split(';').first.trim().toLowerCase() ?? '';
    const Map<String, String> byMime = <String, String>{
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp',
      'image/gif': 'gif',
      'image/avif': 'avif',
      'image/bmp': 'bmp',
    };
    final String? fromMime = byMime[mime];
    if (fromMime != null) {
      return fromMime;
    }
    if (mime.isNotEmpty && !mime.startsWith('image/')) {
      return null;
    }

    final String path = uri.path.toLowerCase();
    for (final String extension in <String>[
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'avif',
      'bmp',
    ]) {
      if (path.endsWith('.$extension')) {
        return extension == 'jpeg' ? 'jpg' : extension;
      }
    }
    return mime.startsWith('image/') ? 'img' : null;
  }

  static bool _isManagedPath(String path) =>
      path.startsWith('images/') &&
      !path.substring('images/'.length).contains('/') &&
      !path.contains('..');

  static String _baseName(String path) =>
      path.split(Platform.pathSeparator).last;
}
