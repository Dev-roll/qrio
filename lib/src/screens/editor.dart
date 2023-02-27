import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/config_items.dart';
import '../widgets/qr_code_preview.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness:
            Theme.of(context).colorScheme.background.computeLuminance() < 0.5
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            Theme.of(context).colorScheme.background.computeLuminance() < 0.5
                ? Brightness.dark
                : Brightness.light,
      ),
    );
    return _Unfocus(
      child: Scaffold(
        body: Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  QrCodePreview(),
                  const ConfigItems(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Unfocus extends StatelessWidget {
  const _Unfocus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
