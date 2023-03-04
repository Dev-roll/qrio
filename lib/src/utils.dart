import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

late TabController tabController;
int selectedIndex = 0;

double defaultSheetHeight(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return sheetMinHeight / screenHeight;
}

int qrErrorCorrectLevelToIndex(int level) {
  return QrErrorCorrectLevel.levels.indexOf(level);
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

Future<List<String?>> selectAndScanImg() async {
  try {
    final inputImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (inputImage == null) return [null];
    final imageTemp = File(inputImage.path);
    return await scanImg(imageTemp.path);
  } on PlatformException catch (e) {
    debugPrint('Failed to pick image: $e');
    return [];
  }
}

Future<List<String>> scanImg(String filePath) async {
  final InputImage inputImage = InputImage.fromFilePath(filePath);
  final barcodeScanner = BarcodeScanner();
  final barcodes = await barcodeScanner.processImage(inputImage);
  if (inputImage.inputImageData?.size == null ||
      inputImage.inputImageData?.imageRotation == null) {
    return barcodes.map((barcode) => barcode.rawValue.toString()).toList();
  }
  return [];
}

updateHistory(String data) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  final String addStr = data.trim();
  if (addStr.isNotEmpty &&
      (historyList.isEmpty || historyList.last != addStr)) {
    historyList.add(addStr);
    await prefs.setStringList('qrio_history', historyList);
    return true;
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

void Function(BuildContext context) openSheetFactory(Widget sheetWidget) {
  return (BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => sheetWidget,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  };
}

Future<int> exportStringListToCsv(List<String> list, String fileName) async {
  List<List<dynamic>> rows = [];

  for (var el in list) {
    rows.add([el]);
  }

  String csv = const ListToCsvConverter().convert(rows);

  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/$fileName.csv');

  try {
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile('$path/$fileName.csv')],
      text: 'QR I/Oの履歴データ',
      subject: 'QR I/Oの履歴データを共有',
    );
    return 0;
  } catch (e) {
    return 1;
  }
}
