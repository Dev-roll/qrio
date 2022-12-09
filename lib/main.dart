import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/screens/home.dart';
import 'src/utils.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme') ?? 'system';
  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith((ref) => stringToThemeMode(theme))
  ], child: const Qrio()));
}

class Qrio extends ConsumerWidget {
  const Qrio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
        builder: ((context, ref, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'qrio',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ja', 'JP')],
            themeMode: ref.watch(themeProvider),
            theme: ThemeData(
                useMaterial3: true,
                // TODO: Set the correct value for colorSchemeSeed
                colorSchemeSeed: Colors.blue,
                brightness: Brightness.light),
            darkTheme: ThemeData(
                useMaterial3: true,
                // TODO: Set the correct value for colorSchemeSeed
                colorSchemeSeed: Colors.blue,
                brightness: Brightness.dark),
            home: const Home())));
  }
}
