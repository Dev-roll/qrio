import 'package:flutter/material.dart';
import 'package:qrio/src/screens/share_app.dart';

import '../constants.dart';
import '../enums/default_popup_menu_items_type.dart';
import '../utils.dart';
import 'select_theme_dialog.dart';

class DefaultPopupMenu extends StatefulWidget {
  const DefaultPopupMenu({super.key});

  @override
  State<DefaultPopupMenu> createState() => _DefaultPopupMenuState();
}

class _DefaultPopupMenuState extends State<DefaultPopupMenu> {
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  final openSelectThemeDialog = openDialogFactory(SelectThemeDialog());

  void _openMenu() {
    _overlayEntry ??= _buildOverlayEntry();

    Overlay.of(context).insert(_overlayEntry!);
    _isMenuOpen = true;
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _isMenuOpen = false;
  }

  OverlayEntry _buildOverlayEntry() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Offset iconButtonPosition =
        renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeMenu,
              onLongPress: _closeMenu,
              onLongPressMoveUpdate: (_) => _closeMenu(),
              onPanDown: (_) => _closeMenu(),
              onPanEnd: (_) => _closeMenu(),
            ),
            Positioned(
              right: 8,
              top: iconButtonPosition.dy + renderBox!.size.height - 4,
              child: Card(
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: defaultPopupMenuItems.map(
                      (e) {
                        return InkWell(
                          onTap: () {
                            _closeMenu();
                            switch (e['value']) {
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
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 48,
                              width: 200,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    e['icon'],
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.75),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    e['label'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(growable: false),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_isMenuOpen) {
          _closeMenu();
        } else {
          _openMenu();
        }
      },
      icon: const Icon(Icons.more_vert_rounded),
      color: Theme.of(context).brightness == Brightness.dark ||
              tabController.index == 0
          ? white
          : black,
    );
  }
}
