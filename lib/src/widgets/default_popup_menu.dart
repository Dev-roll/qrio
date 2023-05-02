import 'package:flutter/material.dart';
import 'package:qrio/src/screens/share_app.dart';

import '../constants.dart';
import '../enums/default_popup_menu_items_type.dart';
import '../utils.dart';
import 'select_theme_dialog.dart';

class DefaultPopupMenu extends StatelessWidget {
  DefaultPopupMenu({super.key});

  final openSelectThemeDialog = openDialogFactory(SelectThemeDialog());

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DefaultPopupMenuItemsType>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 20,
      splashRadius: 20,
      position: PopupMenuPosition.under,
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).brightness == Brightness.dark ||
                selectedIndex == 0
            ? white
            : black,
      ),
      onSelected: ((value) {
        switch (value) {
          case DefaultPopupMenuItemsType.history:
            draggableScrollableController.animateTo(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
            break;
          case DefaultPopupMenuItemsType.selectTheme:
            openSelectThemeDialog(context);
            break;
          // case DefaultPopupMenuItemsType.history:
          //   // Handle this case.
          //   break;
          case DefaultPopupMenuItemsType.about:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const ShareApp();
                },
              ),
            );
            break;
        }
      }),
      itemBuilder: (BuildContext context) => defaultPopupMenuItems.map(
        (e) {
          return PopupMenuItem<DefaultPopupMenuItemsType>(
            value: e['value'],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  e['icon'],
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  e['label'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(growable: false),
    );
  }
}
