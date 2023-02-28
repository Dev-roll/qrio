import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/widgets/bottom_snack_bar.dart';
import 'package:qrio/src/widgets/data_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

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

    var controller = ScrollController();
    final scrollContentHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            appBarHeight +
            qrCodeViewHeight +
            sheetHandleHeight);
    final _ = ref.refresh(futureProvider);
    final asyncValue = ref.watch(futureProvider);
    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.8),
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
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
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
                                          child: const Text('キャンセル'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            deleteHistory();
                                          },
                                          onLongPress: null,
                                          child: Text(
                                            'すべて削除',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
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
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.25),
                ),
                if (List.from(historyList).isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 32),
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
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: sheetHandleHeight),
              height: scrollContentHeight,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    for (var e in List.from(historyList.reversed))
                      InkWell(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(e))) {
                            launchURL(e);
                          } else {
                            Clipboard.setData(
                              ClipboardData(text: e),
                            ).then((value) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
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
                                '$e',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: linkFormat.hasMatch(e.toString())
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                  decoration: linkFormat.hasMatch(e.toString())
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Share.share(
                                      e,
                                      subject: 'QR I/O の履歴共有',
                                    );
                                  },
                                  icon: const Icon(Icons.share_rounded),
                                  padding: const EdgeInsets.all(16.0),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DataBottomSheet(
                                            data: e, ref: ref);
                                      },
                                      backgroundColor: Colors.transparent,
                                    );
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: scrollContentHeight + 50,
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                icon: const Icon(Icons.arrow_upward_rounded),
                label: const Text('履歴のトップ'),
                style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ],
        );
      },
    );
  }
}
