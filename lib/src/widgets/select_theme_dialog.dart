import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../constants.dart';
import '../utils.dart';

class SelectThemeDialog extends ConsumerWidget {
  SelectThemeDialog({Key? key}) : super(key: key);
  final temporaryThemeProvider =
      StateProvider((ref) => ref.watch(themeProvider));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text("テーマの選択"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: selectThemeOption
              .map((e) => RadioListTile<ThemeMode>(
                  title: Text(e['label']),
                  value: e['value'],
                  groupValue: ref.watch(temporaryThemeProvider),
                  onChanged: (ThemeMode? value) =>
                      ref.read(temporaryThemeProvider.notifier).state = value!))
              .toList(growable: false)),
      actions: <Widget>[
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            final selectedTheme = ref.watch(temporaryThemeProvider);
            ref.read(themeProvider.notifier).state = selectedTheme;
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('theme', themeModeToString(selectedTheme));
            // TODO: Refer to https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
