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
            QrCodePreview(),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height *
                              defaultSheetHeight(context) +
                          10,
                    ),
                    padding: const EdgeInsets.only(top: 4),
                    child: const SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 64),
                      child: ConfigItems(),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height *
                              defaultSheetHeight(context) +
                          10,
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
