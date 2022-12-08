import 'package:flutter/material.dart';

import 'widgets/select_theme_dialog.dart';

ThemeMode stringToThemeMode(String theme) {
  switch (theme) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      throw Error();
  }
}

String themeModeToString(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
    default:
      throw Error();
  }
}

void openSelectThemeDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => SelectThemeDialog(),
  );
}
