import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/models/history_model.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/data_bottom_sheet.dart';
import 'package:qrio/src/widgets/history_menu_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  physics: const CustomBouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                  itemCount: hisLen,
                  itemBuilder: (context, i) {
                    // 履歴の並び順を変更するための処理
                    List<int> combinedHistory = [
                      ...newHistory,
                      ...pinnedHistory,
                      ...unpinnedHistory
                    ];
                    // 仮のインデックス
                    int idx = combinedHistory[i];
                    // 履歴DB`historyObj`におけるインデックス
                    int index = hisLen - idx - 1;
                    HistoryModel model = HistoryModel.fromJson(historyObj[idx]);
                    String data = model.data;
                    String type = model.type ?? noData;
                    bool pinned = model.pinned;
                    String createdAt = model.createdAt ?? noData;

                    // 履歴一覧の一番上に表示するアイテムかどうか
                    final isTop = i == 0;

                    bool isRecent = false;
                    if (createdAt != noData) {
                      isRecent = DateTime.now()
                              .difference(parseDate(createdAt))
                              .inSeconds <
                          historyDurationSeconds;
                    }

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(data))) {
                            // ignore: use_build_context_synchronously
                            await launchURL(context, data);
                          } else {
                            await Clipboard.setData(
                              ClipboardData(text: data),
                            ).then((_) {
                              showBottomSnackBar(
                                context,
                                'クリップボードにコピーしました',
                                icon: Icons.library_add_check_rounded,
                              );
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          color: isTop && isRecent
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5)
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: isHistoryExpanded
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  switchPinned(index);
                                },
                                icon: Icon(
                                  pinned
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: pinned
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.all(16.0),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isHistoryExpanded ? 16 : 0,
                                  ),
                                  child: Text(
                                    data,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color:
                                          linkFormat.hasMatch(data.toString())
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                      decoration:
                                          linkFormat.hasMatch(data.toString())
                                              ? TextDecoration.underline
                                              : TextDecoration.none,
                                    ),
                                    overflow: isHistoryExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.fade,
                                    maxLines: isHistoryExpanded ? 100 : 1,
                                    softWrap: isHistoryExpanded,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin:
                                        EdgeInsets.only(left: isRecent ? 4 : 0),
                                    width: isRecent ? 8 : 0,
                                    height: isRecent ? 8 : 0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return DataBottomSheet(
                                            index: index,
                                            data: data,
                                            type: type,
                                            pinned: pinned,
                                            createdAt: createdAt,
                                            ref: ref,
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert_rounded),
                                    padding: const EdgeInsets.all(16.0),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

class CustomBouncingScrollPhysics extends ScrollPhysics {
  const CustomBouncingScrollPhysics({
    this.decelerationRate = ScrollDecelerationRate.normal,
    super.parent,
  });

  final ScrollDecelerationRate decelerationRate;

  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomBouncingScrollPhysics(
        parent: buildParent(ancestor), decelerationRate: decelerationRate);
  }

  double frictionFactor(double overscrollFraction) {
    return 0.01 * math.pow(1 - overscrollFraction, 2);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) => 0.0;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
          spring: spring,
          position: position.pixels,
          velocity: velocity,
          leadingExtent: position.minScrollExtent,
          trailingExtent: position.maxScrollExtent,
          tolerance: tolerance,
          constantDeceleration: 0);
    }
    return null;
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
