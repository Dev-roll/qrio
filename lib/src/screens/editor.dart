import 'package:flutter/material.dart';

import '../widgets/config_items.dart';
import '../widgets/qr_code_preview.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return _Unfocus(
      child: Scaffold(
        body: Form(
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
