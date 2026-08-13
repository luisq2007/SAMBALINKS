import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/metadata/data/queued_metadata_provider.dart';
import 'package:sambalinks/features/metadata/domain/metadata_provider.dart';

class _MeasuringProvider implements MetadataProvider {
  int active = 0;
  int maximumObserved = 0;

  @override
  Future<MetadataResult> fetch(Uri url) async {
    active += 1;
    maximumObserved = active > maximumObserved ? active : maximumObserved;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    active -= 1;
    return MetadataResult(
      title: url.path,
      resolvedUrl: url,
      status: MetadataStatus.partial,
    );
  }
}

void main() {
  test('la cola nunca supera tres descargas simultáneas', () async {
    final _MeasuringProvider delegate = _MeasuringProvider();
    final QueuedMetadataProvider queue = QueuedMetadataProvider(
      delegate,
      maximumConcurrent: 3,
    );

    final List<MetadataResult> results =
        await Future.wait(<Future<MetadataResult>>[
          for (int index = 0; index < 12; index += 1)
            queue.fetch(Uri.parse('https://example.com/$index')),
        ]);

    expect(results, hasLength(12));
    expect(delegate.maximumObserved, 3);
    expect(queue.activeCount, 0);
    expect(queue.pendingCount, 0);
  });

  test('un fallo libera el turno y no atasca la cola', () async {
    int calls = 0;
    final MetadataProvider delegate = _CallbackProvider((Uri url) async {
      calls += 1;
      if (url.path == '/falla') {
        throw StateError('fallo esperado');
      }
      return MetadataResult(resolvedUrl: url, status: MetadataStatus.partial);
    });
    final QueuedMetadataProvider queue = QueuedMetadataProvider(
      delegate,
      maximumConcurrent: 1,
    );

    final Future<MetadataResult> first = queue.fetch(
      Uri.parse('https://example.com/falla'),
    );
    final Future<MetadataResult> second = queue.fetch(
      Uri.parse('https://example.com/sigue'),
    );

    await expectLater(first, throwsStateError);
    expect((await second).resolvedUrl!.path, '/sigue');
    expect(calls, 2);
  });
}

class _CallbackProvider implements MetadataProvider {
  _CallbackProvider(this.callback);

  final Future<MetadataResult> Function(Uri url) callback;

  @override
  Future<MetadataResult> fetch(Uri url) => callback(url);
}
