import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 20,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          clipBehavior: Clip.antiAlias,
          dismissDirection: DismissDirection.horizontal,
          margin: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 40,
          ),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              Expanded(
                child: Text(
                  'アプリを開けません',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ));
      }
    }

    final _ = ref.refresh(futureProvider);
    final asyncValue = ref.watch(futureProvider);
    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 32,
                      ),
                      const Text('履歴'),
                      const SizedBox(
                        width: 28,
                      ),
                      Text(
                        '${List.from(historyList).length}件',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      List.from(historyList).isEmpty
                          ? IconButton(
                              onPressed: null,
                              icon: const Icon(Icons.delete_outline_rounded),
                              disabledColor: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.3),
                              padding: const EdgeInsets.all(16.0),
                            )
                          : IconButton(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded),
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
                              padding: const EdgeInsets.all(16.0),
                            ),
                      const SizedBox(
                        width: 12,
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
                          SnackBar(
                            elevation: 20,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                            behavior: SnackBarBehavior.floating,
                            clipBehavior: Clip.antiAlias,
                            dismissDirection: DismissDirection.horizontal,
                            margin: EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: MediaQuery.of(context).size.height - 160,
                            ),
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: Icon(Icons.library_add_check_rounded),
                                ),
                                Expanded(
                                  child: Text(
                                    'クリップボードにコピーしました',
                                    style: TextStyle(
                                        overflow: TextOverflow.fade,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {},
                            ),
                          ),
                        );
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 32,
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
                      const SizedBox(
                        width: 12,
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
                            onPressed: () {},
                            icon: const Icon(Icons.edit_rounded),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        );
      }, //データ受け取り時
    );
  }
}
