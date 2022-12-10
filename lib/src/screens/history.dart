import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../utils.dart';
// import '../utils.dart';
import '../widgets/default_popup_menu.dart';

final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyList = prefs.getStringList('qrio_history') ?? [];
  return historyList;
});

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.refresh(futureProvider);
    final asyncValue = ref.watch(futureProvider);
    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
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
          //     // updateHistory('hoge');
          //     final _ = ref.refresh(futureProvider);
          //   },
          // ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    for (var i in List.from(historyList.reversed))
                      InkWell(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 36,
                                    ),
                                    Text(
                                      '$i',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                      overflow: TextOverflow.clip,
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
                              height: 12,
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigator.of(context).push();
                        },
                      ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, //データ受け取り時
    );
  }
}
