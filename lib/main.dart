import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/utils.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme') ?? 'system';
  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) {
          return ThemeMode.values.byName(theme);
        })
      ],
      child: const App(),
    ),
  );
}
