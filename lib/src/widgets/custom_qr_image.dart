import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/qr_image_config.dart';

class CustomQrImage extends ConsumerWidget {
  const CustomQrImage({
    super.key,
    this.data,
    this.qrImageConfig,
  })

  /// if [qrImageConfig] is not null, [data] must be null
  : assert(!(qrImageConfig != null) || (data == null));

  final String? data;
  final QrImageConfig? qrImageConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig config = qrImageConfig ?? ref.watch(qrImageConfigProvider);

    final bool isGray = config.qrSeedColor.red == config.qrSeedColor.green &&
        config.qrSeedColor.green == config.qrSeedColor.blue;

    return Theme(
      data: ThemeData(
        colorSchemeSeed: !isGray ? config.qrSeedColor : null,
        primaryColor: isGray ? config.qrSeedColor : null,
      ),
      child: Builder(
        builder: (context) {
          final Color foregroundColor = config.isReversed
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).primaryColor;
          final Color backgroundColor = config.isReversed
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.onPrimary;

          return Container(
            padding: const EdgeInsets.all(16),
            color: backgroundColor,
            child: QrImageView(
              padding: const EdgeInsets.all(0),
              data: data ?? config.data,
              size: config.size,
              backgroundColor: backgroundColor,
              version: config.version,
              errorCorrectionLevel: config.errorCorrectLevel,
              eyeStyle: QrEyeStyle(
                eyeShape: config.eyeShape,
                color: foregroundColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: config.dataModuleShape,
                color: foregroundColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
