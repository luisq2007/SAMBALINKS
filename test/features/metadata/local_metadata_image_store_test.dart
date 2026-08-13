import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/network/http_client.dart';
import 'package:sambalinks/features/metadata/data/local_metadata_image_store.dart';
import 'package:sambalinks/features/metadata/domain/metadata_image_store.dart';

import 'metadata_test_helpers.dart';

void main() {
  late Directory support;

  setUp(() {
    support = Directory.systemTemp.createTempSync('sambalinks-images-');
  });
  tearDown(() => support.delete(recursive: true));

  test('persiste la imagen bajo una ruta relativa y estable', () async {
    final FixtureAdapter adapter = FixtureAdapter(
      (_) => const FixtureResponse(
        body: <int>[137, 80, 78, 71],
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['image/png'],
        },
      ),
    );
    final LocalMetadataImageStore store = LocalMetadataImageStore(
      SafeHttpClient(fixtureDio(adapter)),
      supportDirectory: () async => support,
    );

    final String? relative = await store.persist(
      cardId: 'card:1',
      imageUrl: Uri.parse('https://cdn.example/photo'),
    );

    expect(relative, 'images/card_1.png');
    expect(relative, isNot(startsWith(support.path)));
    expect(File('${support.path}/$relative').readAsBytesSync(), <int>[
      137,
      80,
      78,
      71,
    ]);
  });

  test('rechaza una imagen mayor a 2 MB sin dejar archivos', () async {
    final FixtureAdapter adapter = FixtureAdapter(
      (_) => FixtureResponse(
        body: List<int>.filled(HttpLimits.previewImageBytes + 1, 1),
        headers: <String, List<String>>{
          Headers.contentTypeHeader: const <String>['image/jpeg'],
          Headers.contentLengthHeader: <String>[
            '${HttpLimits.previewImageBytes + 1}',
          ],
        },
      ),
    );
    final LocalMetadataImageStore store = LocalMetadataImageStore(
      SafeHttpClient(fixtureDio(adapter)),
      supportDirectory: () async => support,
    );

    final String? relative = await store.persist(
      cardId: 'card1',
      imageUrl: Uri.parse('https://cdn.example/huge.jpg'),
    );

    expect(relative, isNull);
    expect(Directory('${support.path}/images').existsSync(), isFalse);
  });

  test('limpia huérfanos y conserva imágenes referenciadas', () async {
    final Directory images = Directory('${support.path}/images')
      ..createSync(recursive: true);
    File('${images.path}/keep.jpg').writeAsBytesSync(<int>[1]);
    File('${images.path}/orphan.jpg').writeAsBytesSync(<int>[2]);
    final LocalMetadataImageStore store = LocalMetadataImageStore(
      SafeHttpClient(
        fixtureDio(FixtureAdapter((_) => throw StateError('No usa la red'))),
      ),
      supportDirectory: () async => support,
    );

    final OrphanImageCleanupResult result = await store.cleanupOrphans(<String>{
      'images/keep.jpg',
    }, timeLimit: const Duration(seconds: 1));

    expect(result.scanned, 2);
    expect(result.deleted, 1);
    expect(result.timedOut, isFalse);
    expect(File('${images.path}/keep.jpg').existsSync(), isTrue);
    expect(File('${images.path}/orphan.jpg').existsSync(), isFalse);
  });

  test('delete no permite escapar del directorio administrado', () async {
    final File outside = File('${support.path}/outside.jpg')
      ..writeAsBytesSync(<int>[1]);
    final LocalMetadataImageStore store = LocalMetadataImageStore(
      SafeHttpClient(
        fixtureDio(FixtureAdapter((_) => throw StateError('No usa la red'))),
      ),
      supportDirectory: () async => support,
    );

    await store.delete('../outside.jpg');
    await store.delete('images/../../outside.jpg');

    expect(outside.existsSync(), isTrue);
  });
}
