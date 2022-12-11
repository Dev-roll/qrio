import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../qr_image_config.dart';
import '../widgets/config_items.dart';
import '../widgets/qr_code_preview.dart';

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Form(
          child: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                QrCodePreview(),
                ConfigItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
