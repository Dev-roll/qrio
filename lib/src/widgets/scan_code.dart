import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/bottom_snack_bar.dart';

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<StatefulWidget> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Future<String?> scanSelectedImage() async {
    try {
      final inputImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (inputImage == null) return null;
      final imageTemp = File(inputImage.path);
      return await scanCode(imageTemp.path);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
      return null;
    }
  }

  Future<String> scanCode(String filePath) async {
    final InputImage inputImage = InputImage.fromFilePath(filePath);
    final barcodeScanner = BarcodeScanner();
    final barcodes = await barcodeScanner.processImage(inputImage);
    if (inputImage.inputImageData?.size == null ||
        inputImage.inputImageData?.imageRotation == null) {
      return barcodes.first.rawValue ?? '';
    }
    return '';
  }

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildQrView(context),
            ),
          ),
          Theme(
            data: ThemeData(
              colorSchemeSeed: Theme.of(context).colorScheme.primary,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            child: FutureBuilder(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                return Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).padding.top),
                  child: SizedBox(
                    height: 56,
                    width: 56,
                    child: IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: (snapshot.data != null && snapshot.data == true)
                          ? const Icon(Icons.flashlight_on_rounded)
                          : const Icon(Icons.flashlight_off_rounded),
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                child: Theme(
                  data: ThemeData(
                    colorSchemeSeed: Theme.of(context).colorScheme.primary,
                    brightness: Brightness.dark,
                    useMaterial3: true,
                  ),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () async {
                          final String? data = await scanSelectedImage();
                          if (data != null) {
                            await updateHistory(data);
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              BottomSnackBar(
                                context,
                                'QRコードを読み取れませんでした',
                                foreground:
                                    Theme.of(context).colorScheme.onError,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.collections_rounded),
                        padding: const EdgeInsets.all(20),
                        color: Theme.of(context).colorScheme.onBackground,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height)
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.height * 0.4;
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
        if (scanData.code != null) {
          await updateHistory(scanData.code.toString().trim());
        }
      },
    );
    this.controller!.pauseCamera();
    this.controller!.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        BottomSnackBar(
          context,
          '権限がありません',
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
