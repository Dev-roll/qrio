import 'package:flutter/material.dart';

import '../constants.dart';
import '../utils.dart';

class DefaultPopupMenu extends StatelessWidget {
  const DefaultPopupMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DefaultPopupMenuType>(
        onSelected: ((value) {
          switch (value) {
            case DefaultPopupMenuType.selectTheme:
              openSelectThemeDialog(context);
              break;
            case DefaultPopupMenuType.history:
              // TODO: Handle this case.
              break;
            case DefaultPopupMenuType.about:
              // TODO: Handle this case.
              break;
            case DefaultPopupMenuType.privacyPolicy:
              // TODO: Handle this case.
              break;
            case DefaultPopupMenuType.terms:
              // TODO: Handle this case.
              break;
          }
        }),
        itemBuilder: (BuildContext context) => popupMenuItems
            .map((e) => PopupMenuItem<DefaultPopupMenuType>(
                value: e['value'], child: Text(e['label'])))
            .toList(growable: false));
  }
}
