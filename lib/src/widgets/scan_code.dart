import 'dart:io';
import 'dart:math';

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
    const tabBarWidth = 240.0;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          _buildQrView(context),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color(0x22000000),
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
          Container(
            margin: EdgeInsets.fromLTRB(
              max(
                (MediaQuery.of(context).size.width - tabBarWidth) / 2 - 64,
                0,
              ),
              8,
              8,
              MediaQuery.of(context).size.height * defaultSheetHeight(context) +
                  5,
            ),
            alignment: Alignment.bottomLeft,
            width: MediaQuery.of(context).size.width,
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
                      await addHistoryData(
                          str, historyTypeSelectImg, DateTime.now().toString());
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
    );
  }

  Widget _buildQrView(BuildContext context) {
    final borderColor = white.withOpacity(0.32);
    final squareSize = min(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ) *
        0.5;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            key: qrKey,
            controller: controller,
            onDetect: _onDetect,
          ),
          Container(
            width: squareSize,
            height: squareSize,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height *
                      defaultSheetHeight(context) +
                  20,
            ),
            child: CustomPaint(
              painter: _CornerPainter(
                lineColor: borderColor,
                lineWidth: 3,
                radius: 12,
                cornerSize: 32,
              ),
            ),
          ),
        ],
      ),
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

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.lineColor,
    required this.lineWidth,
    required this.radius,
    required this.cornerSize,
  });

  final Color lineColor;
  final double lineWidth;
  final double radius;
  final double cornerSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, cornerSize)
      ..lineTo(0, radius)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(radius, radius),
          width: radius * 2,
          height: radius * 2,
        ),
        pi,
        pi / 2,
        false,
      )
      ..lineTo(cornerSize, 0)
      ..moveTo(size.width - cornerSize, 0)
      ..lineTo(size.width - radius, 0)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(size.width - radius, radius),
          width: radius * 2,
          height: radius * 2,
        ),
        -pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(size.width, cornerSize)
      ..moveTo(size.width, size.height - cornerSize)
      ..lineTo(size.width, size.height - radius)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(size.width - radius, size.height - radius),
          width: radius * 2,
          height: radius * 2,
        ),
        0,
        pi / 2,
        false,
      )
      ..lineTo(size.width - cornerSize, size.height)
      ..moveTo(cornerSize, size.height)
      ..lineTo(radius, size.height)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(radius, size.height - radius),
          width: radius * 2,
          height: radius * 2,
        ),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(0, size.height - cornerSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.lineWidth != lineWidth;
  }
}
