import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../utils.dart';
import '../widgets/default_popup_menu.dart';
import '../widgets/history.dart';
import '../widgets/qrio.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    const bottomPadding = 24.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          const Qrio(),
          Transform.translate(
            offset: Offset(0, MediaQuery.of(context).padding.top),
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    Theme.of(context)
                                .colorScheme
                                .background
                                .computeLuminance() <
                            0.5
                        ? 'assets/svg/icon_dark.svg'
                        : 'assets/svg/icon_light.svg',
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QR I/O',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(screenWidth / 2 - 28, topPadding),
            child: SizedBox(
              height: 56,
              width: 56,
              child: DefaultPopupMenu(),
            ),
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: defaultSheetHeight,
              minChildSize: defaultSheetHeight,
              maxChildSize: 1 - (topPadding + 56) / screenHeight,
              snap: true,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    color: alphaBlend(
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      Theme.of(context).colorScheme.background,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: const History(),
                  ),
                );
              },
            ),
          ),
          Container(
            height: bottomPadding,
            width: double.infinity,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height - bottomPadding,
            ),
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
