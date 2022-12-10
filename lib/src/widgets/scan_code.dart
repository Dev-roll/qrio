import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<StatefulWidget> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var openUrl = '';
  var _lastChangedDate = DateTime.now();
  final linkTime = 10;
  // ByteData? _image;
  // Image? _image;
  // _doCapture();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _buildQrView(context)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null && snapshot.data == true) {
                      return IconButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {});
                        },
                        icon: const Icon(Icons.flashlight_on_rounded),
                        padding: const EdgeInsets.all(20),
                        style: IconButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      );
                    } else {
                      return IconButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {});
                        },
                        icon: const Icon(Icons.flashlight_off_rounded),
                        padding: const EdgeInsets.all(20),
                        style: IconButton.styleFrom(
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 200,
              )
            ],
          ),
          FloatingActionButton.large(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) {
              //     return const hoge();
              //   }),
              // );
            },
            child: const Icon(Icons.qr_code_2_rounded),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      //   height: 120,
      //   color: Colors.transparent,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       if (result != null)
      //         Text(
      //             'Type: ${describeEnum(result!.format)}, Data: ${result!.code}'),
      //       if (result == null) const Text('Scan a code'),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height)
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.height * 0.4;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: const Color(0xFFFFFFFF),
              borderRadius: 12,
              borderLength: 0,
              borderWidth: 0,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: (MediaQuery.of(context).size.width <
                    MediaQuery.of(context).size.height)
                ? MediaQuery.of(context).size.width * 0.4
                : MediaQuery.of(context).size.height * 0.4,
            height: (MediaQuery.of(context).size.width <
                    MediaQuery.of(context).size.height)
                ? MediaQuery.of(context).size.width * 0.4
                : MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              border: Border.all(color: const Color(0x88FFFFFF), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.center,
        //   child: Icon(
        //     CupertinoIcons.qrcode,
        //     color: const Color(0x32FFFFFF),
        //     size: (MediaQuery.of(context).size.width <
        //             MediaQuery.of(context).size.height)
        //         ? MediaQuery.of(context).size.width * 0.2
        //         : MediaQuery.of(context).size.height * 0.2,
        //   ),
        // ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen(
      (scanData) async {
        log(scanData.code.toString());
        HapticFeedback.vibrate();
        if (scanData != result) {
          setState(() {
            result = scanData;
          });
        }
        if (scanData.code == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 20,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
              content: const Text('コードを読み取れませんでした'),
            ),
          );
        } else if (describeEnum(scanData.format) == 'qrcode') {
          final str = scanData.code.toString();
          final nowDate = DateTime.now();
          if (openUrl != str ||
              nowDate.difference(_lastChangedDate).inSeconds >= linkTime) {
            openUrl = str;
            _lastChangedDate = nowDate;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                behavior: SnackBarBehavior.floating,
                clipBehavior: Clip.antiAlias,
                dismissDirection: DismissDirection.horizontal,
                margin: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 40,
                ),
                duration: Duration(seconds: linkTime),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: await canLaunchUrl(Uri.parse(openUrl.trim()))
                          ? const Icon(Icons.link_rounded)
                          : const Icon(Icons.link_off_rounded),
                    ),
                    Expanded(
                      child: Text(
                        openUrl,
                        style: const TextStyle(overflow: TextOverflow.fade),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Share.share(
                          openUrl.trim(),
                          subject: '読み取った文字列',
                        );
                      },
                      icon: Icon(
                        Icons.share_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: openUrl.trim()),
                        ).then((value) {
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
                                bottom:
                                    MediaQuery.of(context).size.height - 160,
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
                                    child:
                                        Icon(Icons.library_add_check_rounded),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'クリップボードにコピーしました',
                                      style: TextStyle(
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
                        });
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    await canLaunchUrl(Uri.parse(openUrl.trim()))
                        ? IconButton(
                            onPressed: () {
                              _launchURL(openUrl.trim());
                            },
                            icon: Icon(
                              Icons.open_in_new_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.open_in_new_off_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.25),
                            ),
                          ),
                  ],
                ),
                // action: SnackBarAction(
                //   label: '開く',
                //   onPressed: () {

                //   },
                // ),
              ),
            );
          }
        }
      },
    );
    this.controller!.pauseCamera();
    this.controller!.resumeCamera();
  }

  Future _launchURL(String url, {String? secondUrl}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else if (secondUrl != null && await canLaunchUrl(Uri.parse(secondUrl))) {
      await launchUrl(
        Uri.parse(secondUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 20,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAlias,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 40,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Expanded(
              child: Text(
                'アプリを開けません',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ));
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 20,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
          content: const Text('権限がありません'),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
