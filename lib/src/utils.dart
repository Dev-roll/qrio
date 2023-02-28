import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrio/src/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

late TabController tabController;
int selectedIndex = 0;

double defaultSheetHeight(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return sheetMinHeight / screenHeight;
}

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

Color alphaBlend(Color foreground, Color background) {
  final int alpha = foreground.alpha;
  if (alpha == 0x00) {
    // Foreground completely transparent.
    return background;
  }
  final int invAlpha = 0xff - alpha;
  int backAlpha = background.alpha;
  if (backAlpha == 0xff) {
    // Opaque background case
    return Color.fromARGB(
      0xff,
      (alpha * foreground.red + invAlpha * background.red) ~/ 0xff,
      (alpha * foreground.green + invAlpha * background.green) ~/ 0xff,
      (alpha * foreground.blue + invAlpha * background.blue) ~/ 0xff,
    );
  } else {
    // General case
    backAlpha = (backAlpha * invAlpha) ~/ 0xff;
    final int outAlpha = alpha + backAlpha;
    assert(outAlpha != 0x00);
    return Color.fromARGB(
      outAlpha,
      (foreground.red * alpha + background.red * backAlpha) ~/ outAlpha,
      (foreground.green * alpha + background.green * backAlpha) ~/ outAlpha,
      (foreground.blue * alpha + background.blue * backAlpha) ~/ outAlpha,
    );
  }
}

updateHistory(data) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  if (data == []) {
    await prefs.setStringList('qrio_history', []);
  } else if (historyList.isNotEmpty) {
    if (historyList.last != data) {
      historyList.add(data);
      await prefs.setStringList('qrio_history', historyList);
    }
  } else {
    historyList.add(data);
    await prefs.setStringList('qrio_history', historyList);
  }
  // await prefs.setStringList('qrio_history', []);
  // final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  //   return historyList;
  // });
}

deleteHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('qrio_history', []);
}

Future<File> getApplicationDocumentsFile(
    String text, List<int> imageData) async {
  final directory = await getApplicationDocumentsDirectory();

  final exportFile = File('${directory.path}/$text.png');
  if (!await exportFile.exists()) {
    await exportFile.create(recursive: true);
  }
  final file = await exportFile.writeAsBytes(imageData);
  return file;
}

void Function(BuildContext context) openDialogFactory(Widget dialogWidget) {
  return (BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => dialogWidget,
    );
  };
}
