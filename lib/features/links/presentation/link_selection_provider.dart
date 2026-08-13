import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/link_card.dart';

final NotifierProvider<SelectedLinkController, LinkCard?> selectedLinkProvider =
    NotifierProvider<SelectedLinkController, LinkCard?>(
      SelectedLinkController.new,
    );

class SelectedLinkController extends Notifier<LinkCard?> {
  @override
  LinkCard? build() => null;

  void select(LinkCard card) => state = card;

  void clear() => state = null;
}
