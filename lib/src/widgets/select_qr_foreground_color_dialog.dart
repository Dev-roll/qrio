import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';

class SelectQrForegroundColorDialog extends ConsumerWidget {
  const SelectQrForegroundColorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return AlertDialog(
      title: const Text("QRコードの色の選択"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: selectQrColorOptions
            .map((e) => RadioListTile<Color>(
                title: Text(e.label),
                activeColor: Theme.of(context).colorScheme.primary,
                value: e.value,
                groupValue: qrImageConfig.foregroundColor,
                onChanged: (Color? value) {
                  ref
                      .read(qrImageConfigProvider.notifier)
                      .editForegroundColor(foregroundColor: value!);
                  Navigator.of(context).pop();
                }))
            .toList(growable: false),
      ),
    );
  }
}
