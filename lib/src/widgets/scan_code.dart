import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/utils.dart';
import 'package:vibration/vibration.dart';

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<StatefulWidget> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final MobileScannerController controller = MobileScannerController(
      // torchEnabled: false,
      // formats: [BarcodeFormat.qrCode]
      // facing: CameraFacing.front,
      // detectionSpeed: DetectionSpeed.normal
      // detectionTimeoutMs: 1000,
      // returnImage: false,
      );

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    }
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          Positioned.fill(
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
          Container(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              color: Color(0x22000000),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller.torchState,
            builder: (context, state, child) {
              return Transform.translate(
                offset: Offset(0, MediaQuery.of(context).padding.top),
                child: SizedBox(
                  height: appBarHeight,
                  width: appBarHeight,
                  child: IconButton(
                    onPressed: () async {
                      await controller.toggleTorch();
                      setState(() {});
                    },
                    icon: (state == TorchState.on)
                        ? const Icon(Icons.flashlight_on_rounded)
                        : const Icon(Icons.flashlight_off_rounded),
                    color: white,
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () async {
                    final List<String?> data = await selectAndScanImg();
                    if (data.isEmpty) {
                      if (!mounted) return;
                      showBottomSnackBar(
                        context,
                        '検出できませんでした',
                        foreground: Theme.of(context).colorScheme.onError,
                      );
                    } else if (data.contains(null)) {
                      if (!mounted) return;
                      showBottomSnackBar(
                        context,
                        '画像を選択してください',
                        foreground: Theme.of(context).colorScheme.onError,
                      );
                    } else {
                      for (var str in data) {
                        if (str != null) {
                          await addHistoryData(str, historyTypeSelectImg,
                              DateTime.now().toString());
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.collections_rounded),
                  padding: const EdgeInsets.all(20),
                  color: white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          key: qrKey,
          controller: controller,
          onDetect: _onDetect,
        ),
        Container(
          width: (MediaQuery.of(context).size.width <
                  MediaQuery.of(context).size.height)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.height * 0.5,
          height: (MediaQuery.of(context).size.width <
                  MediaQuery.of(context).size.height)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            border: Border.all(color: white.withOpacity(0.25), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Future<void> _onDetect(BarcodeCapture barcodeCapture) async {
    final scannedData = barcodeCapture.barcodes.first.rawValue;

    if (scannedData != null) {
      bool? updated = await addHistoryData(scannedData.toString(),
          barcodeCapture.barcodes.first.format.name, DateTime.now().toString());
      if (updated ?? false) await Vibration.vibrate(duration: 50);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
