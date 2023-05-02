import 'package:flutter/material.dart';
import 'package:qrio/src/constants.dart';

import '../widgets/config_items.dart';
import '../widgets/qr_code_preview.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return _Unfocus(
      child: Scaffold(
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
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: SingleChildScrollView(
                    child: ConfigItems(),
                  ),
                ),
              ),
            ],
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
