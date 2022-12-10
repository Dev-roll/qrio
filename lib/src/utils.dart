import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

updateHistory(data) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  historyList.add(data);
  await prefs.setStringList('qrio_history', historyList);
  // await prefs.setStringList('qrio_history', []);
  // final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  //   return historyList;
  // });
}
