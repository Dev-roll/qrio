import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/main.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/enums/default_popup_menu_items_type.dart';
import 'package:qrio/src/screens/share_app.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/select_theme_dialog.dart';

class DefaultPopupMenu extends ConsumerStatefulWidget {
  const DefaultPopupMenu({super.key});

  @override
  ConsumerState<DefaultPopupMenu> createState() => _DefaultPopupMenuState();
}

class _DefaultPopupMenuState extends ConsumerState<DefaultPopupMenu>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  final openSelectThemeDialog = openDialogFactory(const SelectThemeDialog());
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openMenu() {
    _overlayEntry ??= _buildOverlayEntry();

    Overlay.of(context).insert(_overlayEntry!);
    _isMenuOpen = true;
    _animationController.forward();
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _isMenuOpen = false;
    });
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
              top: iconButtonPosition.dy + renderBox!.size.height - 16,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final offsetY = _animationController.value * 12;
                  final opacity = _animationController.value;
                  final height = _animationController.value *
                      (48 * defaultPopupMenuItems.length + 24);
                  return Transform.translate(
                    offset: Offset(0, offsetY),
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        height: height,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
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
                                  final currentThemeMode =
                                      ref.read(themeModeProvider);
                                  ref
                                      .read(temporaryThemeModeProvider.notifier)
                                      .state = currentThemeMode;
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrioState = ref.watch(qrioStateProvider);
    return IconButton(
      onPressed: () {
        if (_isMenuOpen) {
          _closeMenu();
        } else {
          _openMenu();
        }
      },
      icon: const Icon(Icons.more_vert_rounded),
      color: Theme.of(context).brightness == Brightness.dark
          ? white
          : Color.alphaBlend(
              black.withOpacity(qrioState.tabOffset),
              white,
            ),
    );
  }
}
