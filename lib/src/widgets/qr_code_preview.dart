import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app.dart';
import '../qr_image_config.dart';

class QrCodePreview extends ConsumerWidget {
  const QrCodePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 300,
      child: qrImageConfig.data != ''
          ? QrImage(
              data: qrImageConfig.data,
              size: qrImageConfig.size,
              backgroundColor: qrImageConfig.backgroundColor,
              version: qrImageConfig.version,
              errorCorrectionLevel: qrImageConfig.errorCorrectLevel,
              eyeStyle: QrEyeStyle(
                eyeShape: qrImageConfig.eyeShape,
                color: qrImageConfig.foregroundColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: qrImageConfig.dataModuleShape,
                color: qrImageConfig.foregroundColor,
              ),
            )
          : const SizedBox(child: Text('表示するプレビューがありません。')),
    );
  }
}
