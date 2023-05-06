import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'constants.dart';
import 'qr_image_config.dart';
import 'screens/home.dart';

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
        builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
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
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: lightDynamic?.harmonized().primary ?? seedColor,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: darkDynamic?.harmonized().primary ?? seedColor,
            brightness: Brightness.dark,
          ),
          home: const Home());
    }));
  }
}
