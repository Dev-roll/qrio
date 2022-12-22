import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/widgets/bottom_snack_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../utils.dart';
import '../widgets/config_items.dart';

final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  return historyList;
});

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future launchURL(String url, {String? secondUrl}) async {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else if (secondUrl != null &&
          await canLaunchUrl(Uri.parse(secondUrl))) {
        await launchUrl(
          Uri.parse(secondUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          BottomSnackBar(
            context,
            'アプリを開けません',
            icon: Icons.error_outline_rounded,
            background: Theme.of(context).colorScheme.error,
            foreground: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    }

    final _ = ref.refresh(futureProvider);
    final asyncValue = ref.watch(futureProvider);
    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
        return Column(
          children: [
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
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      '履歴',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Text(
                      '${List.from(historyList).length} 件',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: List.from(historyList).isEmpty
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  icon:
                                      const Icon(Icons.delete_outline_rounded),
                                  title: const Text('削除'),
                                  content: Text(
                                    'すべての履歴を削除しますか？',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        onLongPress: null,
                                        child: const Text('キャンセル')),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        deleteHistory();
                                      },
                                      onLongPress: null,
                                      child: const Text('すべて削除'),
                                    ),
                                  ],
                                ),
                              );
                            },
                      icon: const Icon(Icons.delete_outline_rounded),
                      disabledColor: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.3),
                      padding: const EdgeInsets.all(16.0),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            if (List.from(historyList).isEmpty)
              Column(
                children: [
                  Icon(
                    Icons.update_disabled_rounded,
                    size: 120,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '読み取り・作成の履歴はありません',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            for (var i in List.from(historyList.reversed))
              InkWell(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(i))) {
                    launchURL(i);
                  } else {
                    await Clipboard.setData(
                      ClipboardData(text: i),
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
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Share.share(
                              i,
                              subject: '読み取った文字列',
                            );
                          },
                          icon: const Icon(Icons.share_rounded),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(qrImageConfigProvider.notifier)
                                .editData(data: i);
                            ConfigItems.updateTextFieldValue(i);
                          },
                          icon: const Icon(Icons.more_vert_rounded),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: 28,
            ),
          ],
        );
      }, //データ受け取り時
    );
  }
}
