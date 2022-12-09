import 'package:flutter/material.dart';

const Color baseColor = Colors.blue;

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

const List<Map<String, dynamic>> selectThemeOptions = [
  {'label': 'ライト', 'value': ThemeMode.light},
  {'label': 'ダーク', 'value': ThemeMode.dark},
  {'label': 'システムのデフォルト', 'value': ThemeMode.system}
];
