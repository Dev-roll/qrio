import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/widgets/bottom_snack_bar.dart';
import 'package:qrio/src/widgets/data_bottom_sheet.dart';
import 'package:qrio/src/widgets/history_menu_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

final FutureProvider futureProvider = FutureProvider<dynamic>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(qrioHistoryAsLis) &&
      !prefs.containsKey(qrioHistoryAsStr)) {
    updateHistory();
  }
  // if (!prefs.containsKey(qrioHistoryAsLis) &&
  //     !prefs.containsKey(qrioHistoryAsStr)) {
  //   createHistory();
  // }
  String historyList = prefs.getString(qrioHistoryAsStr) ?? '[]';
  if (historyList.isEmpty) historyList = '[]';
  return historyList;
});

final scrollOffsetProvider = StateProvider<double>((ref) => 0.0);

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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          BottomSnackBar(
            context,
            'アプリを開けません',
            icon: Icons.error_outline_rounded,
            // ignore: use_build_context_synchronously
            background: Theme.of(context).colorScheme.error,
            // ignore: use_build_context_synchronously
            foreground: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    }

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
    return asyncValue.when(
      error: (err, _) => Text(err.toString()), //エラー時
      loading: () => const CircularProgressIndicator(), //読み込み時
      data: (historyList) {
        List<dynamic> historyObj = jsonDecode(historyList) as List<dynamic>;
        if (historyList.toString() == '') historyObj = [];
        historyObj = historyObj.reversed.toList();
        int hisLen = historyObj.length;
        List<int> starredHistory = historyObj
            .asMap()
            .entries
            .where((entry) => entry.value['pinned'])
            .map((entry) => entry.key)
            .toList();
        List<int> unstarredHistory = historyObj
            .asMap()
            .entries
            .where((entry) => !entry.value['pinned'])
            .map((entry) => entry.key)
            .toList();

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
                          if (DateTime.now()
                                  .difference(DateTime.parse(
                                      historyObj.first['created_at']))
                                  .inSeconds <
                              60)
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onError,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: historyObj.isEmpty
                                ? null
                                : () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
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
                    List<int> combinedHistory = [
                      ...starredHistory,
                      ...unstarredHistory
                    ];
                    int idx = combinedHistory[i];
                    int index = hisLen - idx - 1;
                    String data = historyObj[idx]['data'];
                    String type = historyObj[idx]['type'] ?? noData;
                    bool starred = historyObj[idx]['pinned'];
                    String createdAt = historyObj[idx]['created_at'] ?? noData;

                    DateTime createdDateTime = DateTime.parse(createdAt);
                    DateTime now = DateTime.now();
                    Duration diff = now.difference(createdDateTime);
                    bool isRecent = diff.inSeconds < 60;

                    return InkWell(
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse(data))) {
                          launchURL(data);
                        } else {
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
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              switchStarred(index);
                            },
                            icon: Icon(
                              starred
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: starred
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          const SizedBox(width: 0),
                          Expanded(
                            child: Text(
                              data,
                              style: TextStyle(
                                fontSize: 15,
                                color: linkFormat.hasMatch(data.toString())
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                decoration: linkFormat.hasMatch(data.toString())
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
                              if (isRecent)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DataBottomSheet(
                                        index: index,
                                        data: data,
                                        type: type,
                                        starred: starred,
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
    final Tolerance tolerance = this.tolerance;
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
