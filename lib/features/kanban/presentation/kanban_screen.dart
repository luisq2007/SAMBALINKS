import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return EmptyState(
      icon: Icons.view_kanban_outlined,
      title: l10n.kanbanEmptyTitle,
      body: l10n.kanbanEmptyBody,
    );
  }
}
