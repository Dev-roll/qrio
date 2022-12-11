import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/screens/history.dart';
import 'package:qrio/src/widgets/qr_i_o.dart';

import '../widgets/default_popup_menu.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR I/O'),
        centerTitle: true,
        actions: const <Widget>[
          DefaultPopupMenu(),
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          const QRIO(),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: defaultSheetHeight,
              minChildSize: defaultSheetHeight,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
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
        ],
      ),
    );
  }
}
