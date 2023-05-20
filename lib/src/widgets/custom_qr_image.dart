import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/qr_image_config.dart';

class CustomQrImage extends StatelessWidget {
  const CustomQrImage({
    Key? key,
    required this.qrImageConfig,
  }) : super(key: key);

  final QrImageConfig qrImageConfig;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = qrImageConfig.isReversed
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).primaryColor;
    final Color backgroundColor = qrImageConfig.isReversed
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.onPrimary;

    return QrImage(
      padding: const EdgeInsets.all(24),
      data: qrImageConfig.data,
      size: qrImageConfig.size,
      backgroundColor: backgroundColor,
      version: qrImageConfig.version,
      errorCorrectionLevel: qrImageConfig.errorCorrectLevel,
      eyeStyle: QrEyeStyle(
        eyeShape: qrImageConfig.eyeShape,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: qrImageConfig.dataModuleShape,
        color: foregroundColor,
      ),
    );
  }
}
