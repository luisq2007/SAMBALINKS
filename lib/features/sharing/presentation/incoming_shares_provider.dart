import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/share_receiver.dart';
import '../domain/incoming_share.dart';

final NotifierProvider<IncomingSharesController, List<IncomingShare>>
incomingSharesProvider =
    NotifierProvider<IncomingSharesController, List<IncomingShare>>(
      IncomingSharesController.new,
    );

class IncomingSharesController extends Notifier<List<IncomingShare>> {
  late final ShareReceiver _receiver;
  StreamSubscription<List<IncomingShare>>? _subscription;

  @override
  List<IncomingShare> build() {
    _receiver = ShareReceiver();
    _subscription = _receiver.shareStream().listen(_add);
    ref.onDispose(() => _subscription?.cancel());
    unawaited(_loadInitial());
    return <IncomingShare>[];
  }

  Future<void> _loadInitial() async {
    _add(await _receiver.initialShares());
  }

  void _add(List<IncomingShare> incoming) {
    if (incoming.isNotEmpty) {
      state = <IncomingShare>[...incoming.reversed, ...state];
    }
  }

  void dismiss(IncomingShare share) {
    state = <IncomingShare>[
      for (final IncomingShare item in state)
        if (!identical(item, share)) item,
    ];
  }
}
