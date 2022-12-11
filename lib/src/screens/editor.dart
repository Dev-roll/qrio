import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../qr_image_config.dart';
import '../widgets/config_items.dart';
import '../widgets/default_popup_menu.dart';
import '../widgets/qr_code_preview.dart';

final qrImageConfigProvider =
    StateNotifierProvider<QrImageConfigNotifier, QrImageConfig>(
  (ref) => QrImageConfigNotifier(),
);

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
        appBar: AppBar(
            title: const Text('QRコードを新規作成'),
            actions: const <Widget>[DefaultPopupMenu()]),
        body: Form(
          child: Scrollbar(
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
      ),
    );
  }
}
