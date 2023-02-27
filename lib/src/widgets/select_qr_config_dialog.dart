import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils.dart';
import 'select_option.dart';

class SelectQrConfigDialog<T> extends ConsumerWidget {
  const SelectQrConfigDialog({
    required this.title,
    required this.options,
    required this.groupValue,
    required this.editConfigFunc,
    super.key,
  });

  final String title;
  final List<SelectOption<T>> options;
  final T groupValue;
  final Function(T? value) editConfigFunc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (title == 'QR コードの色') {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((e) => RadioListTile<T>(
                    title: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox(width: 24, height: 24),
                            Icon(
                              Icons.circle_rounded,
                              color: e.value as Color,
                              size: groupValue == e.value ? 24 : 20,
                            ),
                            groupValue == e.value
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: alphaBlend(
                                      const Color(0xa0ffffff),
                                      e.value as Color,
                                    ),
                                    size: 20,
                                  ),
                            if (groupValue == e.value)
                              Icon(
                                Icons.circle_outlined,
                                color: alphaBlend(
                                  const Color(0xa0ffffff),
                                  e.value as Color,
                                ),
                              )
                          ],
                        ),
                        const SizedBox(width: 4.0),
                        Text(e.label),
                      ],
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: e.value,
                    groupValue: groupValue,
                    onChanged: (T? value) {
                      editConfigFunc(value);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(growable: false),
        ),
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((e) => RadioListTile<T>(
                    title: Text(e.label),
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: e.value,
                    groupValue: groupValue,
                    onChanged: (T? value) {
                      editConfigFunc(value);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(growable: false),
        ),
      );
    }
  }
}
