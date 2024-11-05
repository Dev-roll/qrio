import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/models/history_model.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/data_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryItem extends HookWidget {
  const HistoryItem({
    super.key,
    required this.history,
    required this.index,
    required this.isTop,
    required this.isHistoryExpanded,
    required this.ref,
  });

  final HistoryModel history;
  final int index;
  final bool isTop;
  final bool isHistoryExpanded;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    String data = history.data;
    String type = history.type ?? noData;
    bool pinned = history.pinned;
    String createdAt = history.createdAt ?? noData;

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    final opacityValue =
        0.1 + (sin(animationController.value * 2 * pi) + 1) / 2.0 * 0.5;

    bool isRecent = false;
    if (createdAt != noData) {
      isRecent = DateTime.now().difference(parseDate(createdAt)).inSeconds <
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
        child: Container(
          color: isTop && isRecent
              ? Theme.of(context).colorScheme.primary.withOpacity(opacityValue)
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
                  pinned ? Icons.star_rounded : Icons.star_border_rounded,
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
                      color: linkFormat.hasMatch(data.toString())
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onBackground,
                      decoration: linkFormat.hasMatch(data.toString())
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
                    margin: EdgeInsets.only(left: isRecent ? 4 : 0),
                    width: isRecent ? 8 : 0,
                    height: isRecent ? 8 : 0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context).colorScheme.error,
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
  }
}
