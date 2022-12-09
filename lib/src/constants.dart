import 'package:flutter/material.dart';

enum DefaultPopupMenuType { history, about, selectTheme, privacyPolicy, terms }

const List<Map<String, dynamic>> popupMenuItems = [
  {'label': '履歴', 'value': DefaultPopupMenuType.history},
  {'label': 'このアプリについて', 'value': DefaultPopupMenuType.about},
  {'label': 'テーマの選択', 'value': DefaultPopupMenuType.selectTheme},
  {'label': 'プライバシーポリシー', 'value': DefaultPopupMenuType.privacyPolicy},
  {'label': '利用規約', 'value': DefaultPopupMenuType.terms}
];

const List<Map<String, dynamic>> selectThemeOption = [
  {'label': 'ライト', 'value': ThemeMode.light},
  {'label': 'ダーク', 'value': ThemeMode.dark},
  {'label': 'システムのデフォルト', 'value': ThemeMode.system}
];
