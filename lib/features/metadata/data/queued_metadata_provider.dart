import 'dart:async';
import 'dart:collection';

import '../domain/metadata_provider.dart';

class _PendingFetch {
  _PendingFetch(this.url, this.completer);

  final Uri url;
  final Completer<MetadataResult> completer;
}

/// Limita las peticiones de metadata sin imponer esa preocupación al dominio.
class QueuedMetadataProvider implements MetadataProvider {
  QueuedMetadataProvider(this._delegate, {this.maximumConcurrent = 3})
    : assert(maximumConcurrent > 0);

  final MetadataProvider _delegate;
  final int maximumConcurrent;
  final Queue<_PendingFetch> _pending = Queue<_PendingFetch>();
  int _active = 0;

  int get activeCount => _active;
  int get pendingCount => _pending.length;

  @override
  Future<MetadataResult> fetch(Uri url) {
    final Completer<MetadataResult> completer = Completer<MetadataResult>();
    _pending.add(_PendingFetch(url, completer));
    _drain();
    return completer.future;
  }

  void _drain() {
    while (_active < maximumConcurrent && _pending.isNotEmpty) {
      final _PendingFetch next = _pending.removeFirst();
      _active += 1;
      Future<MetadataResult>.sync(() => _delegate.fetch(next.url))
          .then(next.completer.complete, onError: next.completer.completeError)
          .whenComplete(() {
            _active -= 1;
            _drain();
          });
    }
  }
}
