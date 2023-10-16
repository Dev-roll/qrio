import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/models/history_model.dart';
import 'package:qrio/src/widgets/bottom_snack_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

late PageController pageController;
final DraggableScrollableController draggableScrollableController =
    DraggableScrollableController();

double defaultSheetHeight(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return sheetMinHeight / screenHeight;
}

int qrErrorCorrectLevelToIndex(int level) {
  return QrErrorCorrectLevel.levels.indexOf(level);
}

ThemeData createTheme(
    ColorScheme? dynamicColor, Brightness brightness, BuildContext context) {
  bool isAndroid = Platform.isAndroid;
  var colorScheme = dynamicColor?.harmonized() ??
      ColorScheme.fromSeed(seedColor: seedColor).harmonized();
  colorScheme = colorScheme.copyWith(brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: isAndroid ? colorScheme : null,
    colorSchemeSeed: isAndroid ? null : colorScheme.primary,
    brightness: brightness,
    visualDensity: VisualDensity.standard,
  );
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

DateTime parseDate(String? dateStr) {
  try {
    return DateTime.parse(dateStr ?? '');
  } catch (e) {
    return DateTime.now().subtract(const Duration(days: 1));
  }
}

Future<void> updateHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList(qrioHistoryAsLis) ?? [];
  final List<dynamic> historyObj = historyList.map((data) {
    return HistoryModel(
      data: data.trim(),
      type: null,
      pinned: false,
      createdAt: DateTime.now().toString(),
    ).toJson();
  }).toList();
  await prefs.setString(qrioHistoryAsStr, jsonEncode(historyObj));
  await prefs.remove(qrioHistoryAsLis);
  debugPrint('*** remove list');
}

Future<void> createHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(qrioHistoryAsStr, '[]');
}

Future<bool?> addHistoryData(
  String data,
  String? type,
  String? createdAt, {
  int index = -1,
  bool pinned = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';
  if (historyList == '') historyList = '[]';
  final List<dynamic> historyObj = jsonDecode(historyList);
  final List<HistoryModel> historyModelList =
      historyObj.map((e) => HistoryModel.fromJson(e)).toList();
  final String addStr = data.trim();
  if (addStr.isNotEmpty &&
      (historyModelList.isEmpty || historyModelList.last.data != addStr)) {
    final addObj = HistoryModel(
      data: addStr,
      type: type,
      pinned: pinned,
      createdAt: createdAt,
    ).toJson();
    if (index < historyObj.length && index >= 0) {
      historyObj.insert(index, addObj);
    } else {
      historyObj.add(addObj);
    }
    await prefs.setString(qrioHistoryAsStr, jsonEncode(historyObj));
    return true;
  }
  return null;
}

Future<void> deleteHistoryData(int index) async {
  final prefs = await SharedPreferences.getInstance();
  String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';
  if (historyList == '') historyList = '[]';
  final List<dynamic> historyObj = jsonDecode(historyList);
  historyObj.removeAt(index);
  await prefs.setString(qrioHistoryAsStr, jsonEncode(historyObj));
}

Future<void> deleteAllHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(qrioHistoryAsStr, '[]');
}

Future<void> switchPinned(int index) async {
  final prefs = await SharedPreferences.getInstance();
  String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';
  if (historyList == '') historyList = '[]';
  final List<dynamic> historyObj = jsonDecode(historyList);
  HistoryModel targetModel = HistoryModel.fromJson(historyObj[index]);
  HistoryModel updatedModel = targetModel.copyWith(pinned: !targetModel.pinned);
  historyObj[index] = updatedModel.toJson();
  await prefs.setString(qrioHistoryAsStr, jsonEncode(historyObj));
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
  return (context) {
    showDialog<void>(
      context: context,
      builder: (context) => dialogWidget,
    );
  };
}

void Function(BuildContext context) openSheetFactory(Widget sheetWidget) {
  return (context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => sheetWidget,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  };
}

void showBottomSnackBar(
  BuildContext context,
  String text, {
  Key? key,
  IconData? icon,
  SnackBarAction? bottomSnackbarAction,
  Color? background,
  Color? foreground,
  int? seconds,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(BottomSnackBar(
    context,
    text,
    key: key,
    icon: icon,
    bottomSnackbarAction: bottomSnackbarAction,
    background: background,
    foreground: foreground,
    seconds: seconds,
  ));
}

Future<int> exportStringListToCsv(String jsonString, String fileName) async {
  final List<dynamic> jsonData = jsonDecode(jsonString);

  final List records = jsonData.map((item) => item.values.toList()).toList();

  final header = jsonData.first.keys.toList();

  String csv =
      const ListToCsvConverter().convert(<List<dynamic>>[header, ...records]);

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

Future<int> exportStringListToJson(String jsonString, String fileName) async {
  final jsonData =
      const JsonEncoder.withIndent('  ').convert(jsonDecode(jsonString));

  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/$fileName.json');

  try {
    await file.writeAsString(jsonData);
    await Share.shareXFiles(
      [XFile('$path/$fileName.json')],
      text: 'QR I/Oの履歴データ',
      subject: 'QR I/Oの履歴データを共有',
    );
    return 0;
  } catch (e) {
    return 1;
  }
}

Future launchURL(BuildContext context, String url, {String? secondUrl}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else if (secondUrl != null && await canLaunchUrl(Uri.parse(secondUrl))) {
    await launchUrl(
      Uri.parse(secondUrl),
      mode: LaunchMode.externalApplication,
    );
  } else {
    // ignore: use_build_context_synchronously
    showBottomSnackBar(
      context,
      'アプリを開けません',
      icon: Icons.error_outline_rounded,
      // ignore: use_build_context_synchronously
      background: Theme.of(context).colorScheme.error,
      // ignore: use_build_context_synchronously
      foreground: Theme.of(context).colorScheme.onError,
    );
  }
}
