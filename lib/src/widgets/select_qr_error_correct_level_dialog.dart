import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';

class SelectQrErrorCorrectLevelDialog extends ConsumerWidget {
  const SelectQrErrorCorrectLevelDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return AlertDialog(
      title: const Text("ErrorCorrectLevel の選択"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: selectQrErrorCorrectLevelOptions
            .map((e) => RadioListTile<int>(
                title: Text(e.label),
                activeColor: Theme.of(context).colorScheme.primary,
                value: e.value,
                groupValue: qrImageConfig.errorCorrectLevel,
                onChanged: (int? value) {
                  ref
                      .read(qrImageConfigProvider.notifier)
                      .editErrorCorrectLevel(errorCorrectLevel: value!);
                  Navigator.of(context).pop();
                }))
            .toList(growable: false),
      ),
    );
  }
}
