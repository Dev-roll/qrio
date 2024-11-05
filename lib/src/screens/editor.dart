import 'package:flutter/material.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/config_items.dart';
import 'package:qrio/src/widgets/qr_code_preview.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top + appBarHeight,
              child: AppBar(
                automaticallyImplyLeading: false,
                surfaceTintColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                // children is reversed
                children: [
                  QrCodePreview(),
                  Padding(
                    padding: const EdgeInsets.only(top: qrCodeViewHeight - 32),
                    child: Stack(
                      children: [
                        // QR Code Config
                        Container(
                          padding: const EdgeInsets.only(top: 4),
                          child: const SingleChildScrollView(
                            padding: EdgeInsets.only(top: 32, bottom: 64),
                            child: ConfigItems(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).colorScheme.background,
                                  Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0),
                                  Theme.of(context).colorScheme.background,
                                  Theme.of(context).colorScheme.background,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ].reversed.toList(),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                      defaultSheetHeight(context) +
                  10,
            )
          ],
        ),
      ),
    );
  }
}
