import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../qr_image_config.dart';
import '../screens/editor.dart';

class QrCodePreview extends ConsumerWidget {
  QrCodePreview({super.key});
  final GlobalKey _globalKey = GlobalKey();

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
      width: 300,
      height: 360,
      // TODO: heightを指定
      child: qrImageConfig.data != ''
          ? Column(
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: QrImage(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: IconButton(
                    onPressed: () async {
                      final bytes = await exportToImage(_globalKey);
                      //byte data→Uint8List
                      final widgetImageBytes = bytes?.buffer.asUint8List(
                          bytes.offsetInBytes, bytes.lengthInBytes);
                      await ImageGallerySaver.saveImage(
                        widgetImageBytes!,
                        name: 'hoge',
                      );
                      // final result =
                      //     await ImageGallerySaver.saveImage(
                      //   widgetImageBytes!,
                      //   name: myCardId,
                      // );
                      //App directoryファイルに保存
                      // final applicationDocumentsFile =
                      //     await getApplicationDocumentsFile(
                      //         myCardId, widgetImageBytes!);
                      // final path = applicationDocumentsFile.path;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 20,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          behavior: SnackBarBehavior.floating,
                          clipBehavior: Clip.antiAlias,
                          dismissDirection: DismissDirection.horizontal,
                          margin: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: MediaQuery.of(context).size.height - 160,
                          ),
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: Icon(Icons.file_download_done_rounded),
                              ),
                              Expanded(
                                child: Text(
                                  'QRコードをダウンロードしました',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      overflow: TextOverflow.fade),
                                ),
                              ),
                            ],
                          ),
                          // duration: const Duration(seconds: 12),
                          action: SnackBarAction(
                            // label: '開く',
                            label: 'OK',
                            onPressed: () {
                              // pickImage();
                              // _launchURL(
                              // '',
                              // 'mailto:example@gmail.com?subject=hoge&body=test',
                              // thunderCardUrl,
                              // 'twitter://user?screen_name=cardseditor',
                              // secondUrl:
                              //     'https://github.com/cardseditor',
                              // );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_alt_rounded),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            )
          : const SizedBox(child: Text('表示するプレビューがありません。')),
    );
  }
}
