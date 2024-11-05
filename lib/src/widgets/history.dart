import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/models/history_model.dart';
import 'package:qrio/src/physics/qrio_scroll_physics.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/history_item.dart';
import 'package:qrio/src/widgets/history_menu_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(qrioHistoryAsLis) &&
      !prefs.containsKey(qrioHistoryAsStr)) {
    await updateHistory();
    debugPrint('''
============================================================
    UPDATED HISTORY
============================================================
''');
  }
  if (!prefs.containsKey(qrioHistoryAsLis) &&
      !prefs.containsKey(qrioHistoryAsStr)) {
    await createHistory();
    debugPrint('''
============================================================
    CREATED HISTORY
============================================================
''');
  }
  String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';
  if (historyList.isEmpty) historyList = '[]';
  return historyList;
});

final scrollOffsetProvider = StateProvider<double>((ref) => 0.0);

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ScrollController();
    var isTop = false;
    controller.addListener(() {
      ref.read(scrollOffsetProvider.notifier).state = controller.offset;
      if (isTop &&
          controller.position.userScrollDirection == ScrollDirection.forward) {
        draggableScrollableController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
      isTop = controller.offset <= 0;
    });
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    const topContentHeight = appBarHeight + qrCodeViewHeight;
    final scrollContentHeight =
        screenHeight - (topPadding + topContentHeight + sheetHandleHeight);
    const maxOffset = 76.0;
    final _ = ref.refresh(futureProvider);
    final asyncValue = ref.watch(futureProvider);
    final offset = ref.watch(scrollOffsetProvider);
    bool isHistoryExpanded = ref.watch(qrioStateProvider).isHistoryExpanded;

    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
        List<dynamic> historyObj = jsonDecode(historyList) as List<dynamic>;
        if (historyList.toString() == '') historyObj = [];
        historyObj = historyObj.reversed.toList();
        int hisLen = historyObj.length;
        List<int> newHistory = historyObj
            .asMap()
            .entries
            .where((entry) {
              final model = HistoryModel.fromJson(entry.value);
              return DateTime.now()
                      .difference(parseDate(model.createdAt!))
                      .inSeconds <
                  historyDurationSeconds;
            })
            .map((entry) => entry.key)
            .toList();
        List<int> pinnedHistory = historyObj
            .asMap()
            .entries
            .where((entry) {
              final model = HistoryModel.fromJson(entry.value);
              return model.pinned && !newHistory.contains(entry.key);
            })
            .map((entry) => entry.key)
            .toList();
        List<int> unpinnedHistory = historyObj
            .asMap()
            .entries
            .where((entry) {
              final model = HistoryModel.fromJson(entry.value);
              return !model.pinned && !newHistory.contains(entry.key);
            })
            .map((entry) => entry.key)
            .toList();
        // 履歴の並び順を変更するための処理
        List<int> combinedHistory = [
          ...newHistory,
          ...pinnedHistory,
          ...unpinnedHistory
        ];
        // 履歴が10件以下であるか否か
        bool isShort = newHistory.length < 10;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight - (topPadding + topContentHeight),
          ),
          child: Stack(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24),
                          Text(
                            '履歴',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '$hisLen 件',
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
                            onPressed: historyObj.isEmpty
                                ? null
                                : () {
                                    ref
                                        .read(qrioStateProvider.notifier)
                                        .setIsHistoryExpanded(
                                            !isHistoryExpanded);
                                  },
                            icon: Icon(
                              isHistoryExpanded
                                  ? Icons.view_agenda_rounded
                                  : Icons.view_headline_rounded,
                            ),
                            disabledColor: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.3),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            clipBehavior: Clip.hardEdge,
                            width: newHistory.isNotEmpty
                                ? isShort
                                    ? badgeSize
                                    : badgeSize +
                                        (newHistory.length.toString().length -
                                                1) *
                                            7
                                : 0,
                            height: newHistory.isNotEmpty ? badgeSize : 0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(badgeSize),
                              color: Theme.of(context).colorScheme.error,
                            ),
                            child: Center(
                              child: hisLen != 0 && newHistory.isNotEmpty
                                  ? Text(
                                      '${newHistory.length}',
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onError,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: historyObj.isEmpty
                                ? null
                                : () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return const HistoryMenuSheet();
                                      },
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                            icon: const Icon(Icons.more_vert_rounded),
                            disabledColor: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.3),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          const SizedBox(width: 4),
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
                  if (historyObj.isEmpty)
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
                child: ListView.builder(
                  controller: controller,
                  physics: const QrioScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                  itemCount: hisLen,
                  itemBuilder: (context, i) {
                    // 履歴一覧の一番上に表示されるアイテムか否か
                    final isTop = i == 0;
                    // 仮のインデックス
                    int idx = combinedHistory[i];
                    // 履歴DB`historyObj`におけるインデックス
                    int index = hisLen - idx - 1;
                    HistoryModel history =
                        HistoryModel.fromJson(historyObj[idx]);
                    return HistoryItem(
                      history: history,
                      index: index,
                      isTop: isTop,
                      isHistoryExpanded: isHistoryExpanded,
                      ref: ref,
                    );
                  },
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: maxOffset,
                  child: SingleChildScrollView(
                    child: Transform.translate(
                      offset: Offset(
                          0, -1 * math.min(offset, maxOffset) + maxOffset),
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
                            backgroundColor:
                                Theme.of(context).colorScheme.onSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
