import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'constants.dart';
// import 'screens/history.dart';
import 'qr_image_config.dart';
import 'screens/home.dart';

final qrImageConfigProvider =
    StateNotifierProvider<QrImageConfigNotifier, QrImageConfig>(
  (ref) => QrImageConfigNotifier(),
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
        builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme = (lightDynamic != null)
          ? lightDynamic.harmonized()
          : ColorScheme.fromSeed(seedColor: baseColor);
      ColorScheme darkColorScheme = (darkDynamic != null)
          ? darkDynamic.harmonized()
          : ColorScheme.fromSeed(
              seedColor: baseColor, brightness: Brightness.dark);

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
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          // home: const History());
          home: const Home());
    }));
  }
}
