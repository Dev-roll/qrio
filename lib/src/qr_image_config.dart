import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

@immutable
class QrImageConfig {
  const QrImageConfig({
    required this.data,
    this.size = 280,
    this.qrSeedColor = const Color(0xFF333333),
    this.version = QrVersions.auto,
    this.errorCorrectLevel = QrErrorCorrectLevel.L,
    this.eyeShape = QrEyeShape.square,
    this.dataModuleShape = QrDataModuleShape.circle,
    this.isReversed = false,
  });

  final String data;
  final double size;
  final Color qrSeedColor;
  final int version;
  final int errorCorrectLevel;
  final QrEyeShape eyeShape;
  final QrDataModuleShape dataModuleShape;
  final bool isReversed;

  QrImageConfig copyWith({
    String? data,
    double? size,
    Color? qrSeedColor,
    int? version,
    int? errorCorrectLevel,
    QrEyeShape? eyeShape,
    QrDataModuleShape? dataModuleShape,
    bool? isReversed,
  }) {
    return QrImageConfig(
      data: data ?? this.data,
      size: size ?? this.size,
      qrSeedColor: qrSeedColor ?? this.qrSeedColor,
      version: version ?? this.version,
      errorCorrectLevel: errorCorrectLevel ?? this.errorCorrectLevel,
      eyeShape: eyeShape ?? this.eyeShape,
      dataModuleShape: dataModuleShape ?? this.dataModuleShape,
      isReversed: isReversed ?? this.isReversed,
    );
  }
}

class QrImageConfigNotifier extends StateNotifier<QrImageConfig> {
  QrImageConfigNotifier() : super(const QrImageConfig(data: ''));

  void editData({required String data}) {
    state = state.copyWith(data: data);
  }

  void editSize({required double size}) {
    state = state.copyWith(size: size);
  }

  void editQrSeedColor({required Color qrSeedColor}) {
    state = state.copyWith(qrSeedColor: qrSeedColor);
  }

  void editVersion({required int version}) {
    state = state.copyWith(version: version);
  }

  void editErrorCorrectLevel({required int errorCorrectLevel}) {
    state = state.copyWith(errorCorrectLevel: errorCorrectLevel);
  }

  void editEyeShape({required QrEyeShape eyeShape}) {
    state = state.copyWith(eyeShape: eyeShape);
  }

  void editDataModuleShape({required QrDataModuleShape dataModuleShape}) {
    state = state.copyWith(dataModuleShape: dataModuleShape);
  }

  void toggleEyeShape() {
    state = state.copyWith(
      eyeShape: state.eyeShape == QrEyeShape.square
          ? QrEyeShape.circle
          : QrEyeShape.square,
    );
  }

  void toggleDataModuleShape() {
    state = state.copyWith(
      dataModuleShape: state.dataModuleShape == QrDataModuleShape.circle
          ? QrDataModuleShape.square
          : QrDataModuleShape.circle,
    );
  }

  void toggleIsReversed() {
    state = state.copyWith(isReversed: !state.isReversed);
  }

  void reset() {
    state = const QrImageConfig(data: '');
  }
}
