import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/main.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/screens/home.dart';

final qrImageConfigProvider =
    StateNotifierProvider<QrImageConfigNotifier, QrImageConfig>(
  (ref) => QrImageConfigNotifier(),
);
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ThemeData baseTheme(ColorScheme? dynamicColor, Brightness brightness,
        bool isAndroid, BuildContext context) {
      var colorScheme = dynamicColor?.harmonized() ??
          ColorScheme.fromSeed(seedColor: seedColor).harmonized();
      return ThemeData(
        useMaterial3: true,
        colorScheme: isAndroid ? colorScheme : null,
        colorSchemeSeed: isAndroid ? null : colorScheme.primary,
        brightness: brightness,
        visualDensity: VisualDensity.standard,
      );
    }

    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
        bool isAndroid = Platform.isAndroid;

        ThemeData theme(ColorScheme? dynamicColor) {
          return baseTheme(dynamicColor, Brightness.light, isAndroid, context);
        }

        ThemeData darkTheme(ColorScheme? dynamicColor) {
          return baseTheme(dynamicColor, Brightness.dark, isAndroid, context);
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QR I/O',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ja', 'JP')],
          themeMode: themeMode,
          theme: theme(lightDynamic),
          darkTheme: darkTheme(darkDynamic),
          home: const Home(),
        );
      }),
    );
  }
}
