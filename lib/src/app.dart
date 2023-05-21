import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/main.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/screens/home.dart';
import 'package:qrio/src/utils.dart';

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

    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
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
          theme: createTheme(lightDynamic, Brightness.light, context),
          darkTheme: createTheme(darkDynamic, Brightness.dark, context),
          home: const Home(),
        );
      }),
    );
  }
}
