import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../utils.dart';
import 'bottom_snack_bar.dart';
import 'config_items.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key, required this.data, required this.ref});
  final String data;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 440,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: alphaBlend(
          Theme.of(context).colorScheme.primary.withOpacity(0.08),
          Theme.of(context).colorScheme.surface,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 88,
            margin: const EdgeInsets.only(top: 12),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(data),
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 4,
            endIndent: 4,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 44,
              ),
              Icon(
                Icons.info_outline_rounded,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                '${data.length}文字',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              Clipboard.setData(
                ClipboardData(text: data),
              ).then((value) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  BottomSnackBar(
                    context,
                    'クリップボードにコピーしました',
                    icon: Icons.library_add_check_rounded,
                  ),
                );
              });
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 44,
                ),
                Icon(
                  Icons.copy_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  'クリップボードにコピー',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              Share.share(data, subject: 'QR I/O の履歴共有');
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 44,
                ),
                Icon(
                  Icons.share_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  '共有',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              ref.read(qrImageConfigProvider.notifier).editData(data: data);
              ConfigItems.updateTextFieldValue(data);
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 44,
                ),
                Icon(
                  Icons.edit_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  'QRコードを作成',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              // TODO:delete
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 44,
                ),
                Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  '削除',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
