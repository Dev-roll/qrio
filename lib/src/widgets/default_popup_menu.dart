import 'package:flutter/material.dart';

import '../constants.dart';
import '../utils.dart';

class DefaultPopupMenu extends StatelessWidget {
  const DefaultPopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DefaultPopupMenuItemsType>(
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
            case DefaultPopupMenuItemsType.privacyPolicy:
              // TODO: Handle this case.
              break;
            case DefaultPopupMenuItemsType.terms:
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
