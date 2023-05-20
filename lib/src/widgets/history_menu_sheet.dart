import 'package:flutter/material.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryMenuSheet extends StatelessWidget {
  const HistoryMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 16),
              Text(
                'すべての履歴',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            indent: 4,
            endIndent: 4,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';

              if (historyList.isEmpty) {
                return;
              }

              final responseStatus =
                  await exportStringListToCsv(historyList, 'qrio_history');

              if (responseStatus != 0) {
                // TODO: エラー処理
                throw Error();
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 52,
                ),
                Icon(
                  Icons.share_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Text(
                  'CSVで共有',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'qrio_history.csv',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';

              if (historyList.isEmpty) {
                return;
              }

              final responseStatus =
                  await exportStringListToJson(historyList, 'qrio_history');

              if (responseStatus != 0) {
                // TODO: エラー処理
                throw Error();
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 52,
                ),
                Icon(
                  Icons.share_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Text(
                  'JSONで共有',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'qrio_history.json',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                  title: const Text('削除'),
                  content: Text(
                    'すべての履歴を削除しますか？',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => {Navigator.pop(context)},
                      onLongPress: null,
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteAllHistory();
                      },
                      onLongPress: null,
                      child: Text(
                        'すべて削除',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
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
                const SizedBox(width: 12),
                Text(
                  'すべての履歴を削除',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
