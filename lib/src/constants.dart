import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'enums/default_popup_menu_items_type.dart';
import 'widgets/select_option.dart';

const Color seedColor = Color(0xFF30A3F0);
const Color white = Color(0xEEFFFFFF);
const Color black = Color(0xEE000000);

const double appBarHeight = 56;
const double qrCodeViewHeight = 272;
const double bottomPadding = 16;
const double sheetMinHeight = 152;
const double sheetHandleHeight = 77;

const List<Map<String, dynamic>> defaultPopupMenuItems = [
  // {
  //   'label': '履歴',
  //   'value': DefaultPopupMenuItemsType.history,
  //   'icon': Icons.history_rounded,
  // },
  {
    'label': 'このアプリについて',
    'value': DefaultPopupMenuItemsType.about,
    'icon': Icons.description_outlined,
  },
  {
    'label': 'テーマの選択',
    'value': DefaultPopupMenuItemsType.selectTheme,
    'icon': Icons.brightness_medium_rounded,
  },
];

final SelectOptionGroup<ThemeMode> selectThemeOptionGroup = SelectOptionGroup(
  title: 'テーマの選択',
  icon: Icons.brightness_medium_rounded,
  options: [
    SelectOption<ThemeMode>(label: 'ライト', value: ThemeMode.light),
    SelectOption<ThemeMode>(label: 'ダーク', value: ThemeMode.dark),
    SelectOption<ThemeMode>(label: 'システムのデフォルト', value: ThemeMode.system),
  ],
);

final SelectOptionGroup<QrEyeShape> selectQrEyeShapeOptionGroup =
    SelectOptionGroup(
  title: '切り出しシンボルの形',
  icon: Icons.all_out_rounded,
  options: [
    SelectOption<QrEyeShape>(label: '丸', value: QrEyeShape.circle),
    SelectOption<QrEyeShape>(label: '四角', value: QrEyeShape.square),
  ],
);

final SelectOptionGroup<QrDataModuleShape> selectQrDataModuleShapeOptionGroup =
    SelectOptionGroup(
  title: 'セルの形',
  icon: Icons.apps_rounded,
  options: [
    SelectOption<QrDataModuleShape>(
        label: '丸', value: QrDataModuleShape.circle),
    SelectOption<QrDataModuleShape>(
        label: '四角', value: QrDataModuleShape.square),
  ],
);

final SelectOptionGroup<int> selectQrErrorCorrectLevelOptionGroup =
    SelectOptionGroup(
  title: '誤り訂正能力',
  icon: Icons.check_circle_outline_rounded,
  options: [
    SelectOption<int>(label: 'レベル H', value: QrErrorCorrectLevel.H),
    SelectOption<int>(label: 'レベル L', value: QrErrorCorrectLevel.L),
    SelectOption<int>(label: 'レベル M', value: QrErrorCorrectLevel.M),
    SelectOption<int>(label: 'レベル Q', value: QrErrorCorrectLevel.Q),
  ],
);

final SelectOptionGroup<Color> selectQrSeedColorOptionGroup = SelectOptionGroup(
  title: 'QR コードの色',
  icon: Icons.palette_outlined,
  options: [
    // SelectOption<Color>(label: 'ホワイト', value: const Color(0xFFFFFFFF)),
    SelectOption<Color>(label: 'ブラック', value: const Color(0xFF333333)),
    SelectOption<Color>(label: 'ブルー', value: Colors.blue),
    SelectOption<Color>(label: 'ピンク', value: Colors.pink),
    SelectOption<Color>(label: 'オレンジ', value: Colors.orange),
    SelectOption<Color>(label: 'グリーン', value: Colors.green),
    SelectOption<Color>(label: 'パープル', value: Colors.purple),
  ],
);

RegExp linkFormat = RegExp(
    r'((https?:\/\/)|(https?:www\.)|(www\.))[a-zA-Z0-9-]{1,256}\.[a-zA-Z0-9]{2,6}(\/[a-zA-Z0-9亜-熙ぁ-んァ-ヶ()@:%_\+.~#?&\/=-]*)?');
