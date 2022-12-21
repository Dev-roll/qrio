import 'package:flutter/material.dart';

import '../constants.dart';
import 'select_theme_dialog.dart';

class DefaultPopupMenu extends StatelessWidget {
  const DefaultPopupMenu({Key? key}) : super(key: key);

  void openSelectThemeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => SelectThemeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DefaultPopupMenuItemsType>(
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
        itemBuilder: (BuildContext context) => defaultPopupMenuItems
            .map((e) => PopupMenuItem<DefaultPopupMenuItemsType>(
                value: e['value'], child: Text(e['label'])))
            .toList(growable: false));
  }
}
