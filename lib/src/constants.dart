import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const Color seedColor = Colors.blue;

enum DefaultPopupMenuItemsType {
  history,
  about,
  selectTheme,
  privacyPolicy,
  terms
}

const List<Map<String, dynamic>> defaultPopupMenuItems = [
  {'label': '履歴', 'value': DefaultPopupMenuItemsType.history},
  {'label': 'このアプリについて', 'value': DefaultPopupMenuItemsType.about},
  {'label': 'テーマの選択', 'value': DefaultPopupMenuItemsType.selectTheme},
  {'label': 'プライバシーポリシー', 'value': DefaultPopupMenuItemsType.privacyPolicy},
  {'label': '利用規約', 'value': DefaultPopupMenuItemsType.terms}
];

const defaultSheetHeight = 0.2;

class SelectOption<T> {
  final String label;
  final T value;
  final String? description;

  SelectOption({required this.label, required this.value, this.description});
}

// class SelectOptionList<T> extends List<SelectOption<T>> {
//   final List<SelectOption<T>> options;

//   SelectOptionList(this.options);

//   SelectOption getOptionFromValue(T value) {
//     for (var e in options) {
//       if (e.value == value) return e;
//     }
//     throw Error();
//   }
// }

// final SelectOptionList<ThemeMode> selectThemeOptions =
//     SelectOptionList<ThemeMode>([
//   SelectOption<ThemeMode>(label: 'ライト', value: ThemeMode.light),
//   SelectOption<ThemeMode>(label: 'ダーク', value: ThemeMode.dark),
//   SelectOption<ThemeMode>(label: 'システムのデフォルト', value: ThemeMode.system),
// ]);

// final SelectOptionList<QrEyeShape> selectQrEyeShapeOptions =
//     SelectOptionList<QrEyeShape>([
//   SelectOption<QrEyeShape>(label: 'Circle', value: QrEyeShape.circle),
//   SelectOption<QrEyeShape>(label: 'Square', value: QrEyeShape.square),
// ]);

// final SelectOptionList<QrDataModuleShape> selectQrDataModuleShapeOptions =
//     SelectOptionList<QrDataModuleShape>([
//   SelectOption<QrDataModuleShape>(
//       label: 'Circle', value: QrDataModuleShape.circle),
//   SelectOption<QrDataModuleShape>(
//       label: 'Square', value: QrDataModuleShape.square),
// ]);

// final SelectOptionList<int> selectQrErrorCorrectLevelOptions =
//     SelectOptionList([
//   SelectOption(label: 'H', value: QrErrorCorrectLevel.H),
//   SelectOption(label: 'L', value: QrErrorCorrectLevel.L),
//   SelectOption(label: 'M', value: QrErrorCorrectLevel.M),
//   SelectOption(label: 'Q', value: QrErrorCorrectLevel.Q),
// ]);
final List<SelectOption<ThemeMode>> selectThemeOptions = [
  SelectOption<ThemeMode>(label: 'ライト', value: ThemeMode.light),
  SelectOption<ThemeMode>(label: 'ダーク', value: ThemeMode.dark),
  SelectOption<ThemeMode>(label: 'システムのデフォルト', value: ThemeMode.system),
];

final List<SelectOption<QrEyeShape>> selectQrEyeShapeOptions = [
  SelectOption<QrEyeShape>(label: 'Circle', value: QrEyeShape.circle),
  SelectOption<QrEyeShape>(label: 'Square', value: QrEyeShape.square),
];

final List<SelectOption<QrDataModuleShape>> selectQrDataModuleShapeOptions = [
  SelectOption<QrDataModuleShape>(
      label: 'Circle', value: QrDataModuleShape.circle),
  SelectOption<QrDataModuleShape>(
      label: 'Square', value: QrDataModuleShape.square),
];

final List<SelectOption<int>> selectQrErrorCorrectLevelOptions = [
  SelectOption(label: 'H', value: QrErrorCorrectLevel.H),
  SelectOption(label: 'L', value: QrErrorCorrectLevel.L),
  SelectOption(label: 'M', value: QrErrorCorrectLevel.M),
  SelectOption(label: 'Q', value: QrErrorCorrectLevel.Q),
];

final List<SelectOption<Color>> selectQrColorOptions = [
  SelectOption(label: 'ホワイト', value: const Color(0xFFFFFFFF)),
  SelectOption(label: 'ブラック', value: const Color(0xFF333333)),
  SelectOption(label: 'ブルー', value: Colors.blue),
  SelectOption(label: 'ピンク', value: Colors.pink),
  SelectOption(label: 'オレンジ', value: Colors.orange),
  SelectOption(label: 'グリーン', value: Colors.green),
];

SelectOption getOptionFromValue(dynamic value, List<SelectOption> options) {
  for (var e in options) {
    if (e.value == value) return e;
  }
  throw Error();
}
