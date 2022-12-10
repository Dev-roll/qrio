import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../utils.dart';
import '../widgets/default_popup_menu.dart';

final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('items', [
    'https://github.com/Dev-roll/thundercard',
    'https://github.com/cardseditor/portfolio',
    'https://twitter.com/cardseditor',
    'https://www.instagram.com/cardseditor/',
    'https://flutter.dev/',
    'https://pub.dev/packages/shared_preferences',
    'https://pub.dev/packages/qr_flutter',
    'https://nextjs.org/',
    'https://zenn.dev/kazutxt/books/flutter_practice_introduction',
    'https://qiita.com/advent-calendar/2022/gajeroll',
    'https://github.com/Dev-roll/thundercard',
    'https://github.com/cardseditor/portfolio',
    'https://twitter.com/cardseditor',
    'https://www.instagram.com/cardseditor/',
    'https://flutter.dev/',
    'https://pub.dev/packages/shared_preferences',
    'https://pub.dev/packages/qr_flutter',
    'https://nextjs.org/',
    'https://zenn.dev/kazutxt/books/flutter_practice_introduction',
    'https://qiita.com/advent-calendar/2022/gajeroll',
  ]);
  final List? items = prefs.getStringList('items');
  return items;
});

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(futureProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        actions: const <Widget>[
          DefaultPopupMenu(),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.refresh),
      //   onPressed: () {
      //     // 状態を更新する
      //     ref.refresh(futureProvider);
      //   },
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              asyncValue.when(
                error: (err, _) => Text(err.toString()), //エラー時
                loading: () => const CircularProgressIndicator(), //読み込み時
                data: (data) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      for (var i in data)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 36,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$i',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                                // Row(
                                //   children: const [
                                //     Icon(Icons.content_copy_rounded),
                                //     SizedBox(
                                //       width: 24,
                                //     ),
                                //     Icon(Icons.edit_rounded),
                                //     SizedBox(
                                //       width: 24,
                                //     ),
                                //     Icon(Icons.delete_rounded),
                                //     SizedBox(
                                //       width: 48,
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                    ],
                  );
                }, //データ受け取り時
              ),
            ],
          ),
        ),
      ),
    );
  }
}
