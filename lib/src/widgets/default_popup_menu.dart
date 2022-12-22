import 'package:flutter/material.dart';

import '../constants.dart';
import '../utils.dart';
import 'select_theme_dialog.dart';

class DefaultPopupMenu extends StatelessWidget {
  DefaultPopupMenu({super.key});

  final openSelectThemeDialog = openDialogFactory(SelectThemeDialog());

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DefaultPopupMenuItemsType>(
      color: alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.12),
        Theme.of(context).colorScheme.surface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      splashRadius: 20,
      position: PopupMenuPosition.under,
      onSelected: ((value) {
        switch (value) {
          case DefaultPopupMenuItemsType.selectTheme:
            openSelectThemeDialog(context);
            break;
          case DefaultPopupMenuItemsType.history:
            // TODO: Handle this case.
            break;
          case DefaultPopupMenuItemsType.about:
            // TODO: Handle this case.
            break;
        }
      }),
      itemBuilder: (BuildContext context) => defaultPopupMenuItems.map(
        (e) {
          return PopupMenuItem<DefaultPopupMenuItemsType>(
            value: e['value'],
            child: Text(
              e['label'],
            ),
          );
        },
      ).toList(growable: false),
    );
  }
}
