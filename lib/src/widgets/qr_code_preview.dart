import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../qr_image_config.dart';
import '../utils.dart';

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

    return Container(
      alignment: Alignment.center,
      height: 284,
      child: qrImageConfig.data != ''
          ? Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  height: 200,
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: QrImage(
                        padding: const EdgeInsets.all(24),
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
                        onPressed: () async {
                          final bytes = await exportToImage(_qrKey);
                          final widgetImageBytes = bytes?.buffer.asUint8List(
                              bytes.offsetInBytes, bytes.lengthInBytes);
                          String year = (DateTime.now().year % 100).toString();
                          String month =
                              (DateTime.now().month).toString().padLeft(2, '0');
                          String day =
                              (DateTime.now().day).toString().padLeft(2, '0');
                          await ImageGallerySaver.saveImage(
                            widgetImageBytes!,
                            name: 'QRIO_$year$month$day',
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 20,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              behavior: SnackBarBehavior.floating,
                              clipBehavior: Clip.antiAlias,
                              dismissDirection: DismissDirection.horizontal,
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 80,
                              ),
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                    child:
                                        Icon(Icons.file_download_done_rounded),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'QRコードをダウンロードしました',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          overflow: TextOverflow.fade),
                                    ),
                                  ),
                                ],
                              ),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_alt_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: qrImageConfig.data),
                          ).then(
                            (value) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 20,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                behavior: SnackBarBehavior.floating,
                                clipBehavior: Clip.antiAlias,
                                dismissDirection: DismissDirection.horizontal,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 80,
                                ),
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                      child:
                                          Icon(Icons.library_add_check_rounded),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'クリップボードにコピーしました',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            overflow: TextOverflow.fade),
                                      ),
                                    ),
                                  ],
                                ),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox(child: Text('表示するプレビューがありません。')),
    );
  }
}
