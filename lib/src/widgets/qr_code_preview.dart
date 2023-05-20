import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/custom_qr_image.dart';
import 'package:share_plus/share_plus.dart';

class QrCodePreview extends ConsumerWidget {
  QrCodePreview({super.key});
  final GlobalKey _qrKey = GlobalKey();

  Future<ByteData?> exportToImage(GlobalKey globalKey) async {
    final boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: 3,
    );
    final byteData = image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);
    final bool isGray =
        qrImageConfig.qrSeedColor.red == qrImageConfig.qrSeedColor.green &&
            qrImageConfig.qrSeedColor.green == qrImageConfig.qrSeedColor.blue;

    return Container(
      alignment: Alignment.center,
      height: qrCodeViewHeight,
      child: qrImageConfig.data != ''
          ? Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  height: 200,
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: Theme(
                        data: ThemeData(
                            colorSchemeSeed:
                                !isGray ? qrImageConfig.qrSeedColor : null,
                            primaryColor:
                                isGray ? qrImageConfig.qrSeedColor : null),
                        child: CustomQrImage(qrImageConfig: qrImageConfig),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final bytes = await exportToImage(_qrKey);
                          final widgetImageBytes = bytes?.buffer.asUint8List(
                              bytes.offsetInBytes, bytes.lengthInBytes);
                          final applicationDocumentsFile =
                              await getApplicationDocumentsFile(
                                  'qrImage', widgetImageBytes!);
                          final path = applicationDocumentsFile.path;
                          await Share.shareXFiles(
                            [XFile(path)],
                            text: qrImageConfig.data,
                            subject: 'QR I/O で作成したQRコードの共有',
                          );
                          applicationDocumentsFile.delete();
                        },
                        icon: const Icon(Icons.share_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                      IconButton(
                        onPressed: () {
                          String year = (DateTime.now().year % 100).toString();
                          String month =
                              (DateTime.now().month).toString().padLeft(2, '0');
                          String day =
                              (DateTime.now().day).toString().padLeft(2, '0');
                          exportToImage(_qrKey)
                              .then((value) => value?.buffer.asUint8List(
                                  value.offsetInBytes, value.lengthInBytes))
                              .then((value) => ImageGallerySaver.saveImage(
                                    value!,
                                    name: 'QRIO_$year$month$day',
                                  ))
                              .then(
                            (_) {
                              showBottomSnackBar(
                                context,
                                'QRコードをダウンロードしました',
                                icon: Icons.file_download_done_rounded,
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.save_alt_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: qrImageConfig.data),
                          ).then((_) {
                            showBottomSnackBar(
                              context,
                              'クリップボードにコピーしました',
                              icon: Icons.library_add_check_rounded,
                            );
                          });
                        },
                        icon: const Icon(Icons.copy_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 200,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.3),
                ),
                Text(
                  '表示するプレビューがありません',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
