import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/default_popup_menu.dart';
import 'package:qrio/src/widgets/history.dart';
import 'package:qrio/src/widgets/qrio.dart';
import 'package:qrio/src/widgets/unfocus.dart';

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
    const topContentHeight = appBarHeight + qrCodeViewHeight;
    final qrioState = ref.watch(qrioStateProvider);

    return Unfocus(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
            ),
            const Qrio(),
            Transform.translate(
              offset: Offset(0, MediaQuery.of(context).padding.top),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/icon_light.svg',
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).brightness == Brightness.dark
                            ? white
                            : Color.alphaBlend(
                                black.withOpacity(qrioState.tabOffset),
                                white,
                              ),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'QR I/O',
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? white
                            : Color.alphaBlend(
                                black.withOpacity(qrioState.tabOffset),
                                white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(screenWidth / 2 - 28, topPadding),
              child: const SizedBox(
                height: 56,
                width: 56,
                child: DefaultPopupMenu(),
              ),
            ),
            SizedBox.expand(
              child: DraggableScrollableSheet(
                controller: draggableScrollableController,
                initialChildSize: defaultSheetHeight(context),
                minChildSize: defaultSheetHeight(context),
                maxChildSize:
                    1 - (topPadding + topContentHeight) / screenHeight,
                snap: true,
                builder: (context, scrollController) {
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
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - bottomPadding,
              ),
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
