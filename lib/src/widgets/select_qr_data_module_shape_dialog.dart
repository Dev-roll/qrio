import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';

class SelectQrDataModuleShapeDialog extends ConsumerWidget {
  const SelectQrDataModuleShapeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return AlertDialog(
      title: const Text("DataModuleShape の選択"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: selectQrDataModuleShapeOptions
            .map((e) => RadioListTile<QrDataModuleShape>(
                title: Text(e.label),
                activeColor: Theme.of(context).colorScheme.primary,
                value: e.value,
                groupValue: qrImageConfig.dataModuleShape,
                onChanged: (QrDataModuleShape? value) {
                  ref
                      .read(qrImageConfigProvider.notifier)
                      .editDataModuleShape(dataModuleShape: value!);
                  Navigator.of(context).pop();
                }))
            .toList(growable: false),
      ),
    );
  }
}
