import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

@immutable
class QrImageConfig {
  const QrImageConfig({
    required this.data,
    this.size = 280,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor = const Color(0xFF333333),
    this.version = QrVersions.auto,
    this.errorCorrectLevel = QrErrorCorrectLevel.L,
    this.eyeShape = QrEyeShape.square,
    this.dataModuleShape = QrDataModuleShape.circle,
  });

  final String data;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final int version;
  final int errorCorrectLevel;
  final QrEyeShape eyeShape;
  final QrDataModuleShape dataModuleShape;

  QrImageConfig copyWith({
    String? data,
    double? size,
    Color? backgroundColor,
    Color? foregroundColor,
    int? version,
    int? errorCorrectLevel,
    QrEyeShape? eyeShape,
    QrDataModuleShape? dataModuleShape,
  }) {
    return QrImageConfig(
      data: data ?? this.data,
      size: size ?? this.size,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      version: version ?? this.version,
      errorCorrectLevel: errorCorrectLevel ?? this.errorCorrectLevel,
      eyeShape: eyeShape ?? this.eyeShape,
      dataModuleShape: dataModuleShape ?? this.dataModuleShape,
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

  void editBackgroundColor({required Color backgroundColor}) {
    state = state.copyWith(backgroundColor: backgroundColor);
  }

  void editForegroundColor({required Color foregroundColor}) {
    state = state.copyWith(foregroundColor: foregroundColor);
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

  void reset() {
    state = const QrImageConfig(data: '');
  }
}
