import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../constants.dart';
import '../utils.dart';

class SelectThemeDialog extends ConsumerWidget {
  SelectThemeDialog({Key? key}) : super(key: key);
  final temporaryThemeModeProvider =
      StateProvider((ref) => ref.watch(themeModeProvider));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      icon: Icon(selectThemeOptionGroup.icon),
      title: Text(selectThemeOptionGroup.title),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: selectThemeOptionGroup.options
              .map((e) => RadioListTile<ThemeMode>(
                  title: Text(e.label),
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: e.value,
                  groupValue: ref.watch(temporaryThemeModeProvider),
                  onChanged: (ThemeMode? value) => ref
                      .read(temporaryThemeModeProvider.notifier)
                      .state = value!))
              .toList(growable: false)),
      actions: <Widget>[
        TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            final selectedTheme = ref.watch(temporaryThemeModeProvider);
            ref.read(themeModeProvider.notifier).state = selectedTheme;
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('theme', themeModeToString(selectedTheme));
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
