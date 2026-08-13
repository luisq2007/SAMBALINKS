import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class SambaSheet extends StatelessWidget {
  const SambaSheet({
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool showDragHandle = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: true,
      useSafeArea: true,
      showDragHandle: showDragHandle,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.xl,
        top: Spacing.sm,
        right: Spacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Spacing.lg),
          Flexible(fit: FlexFit.loose, child: child),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: Spacing.xl),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
