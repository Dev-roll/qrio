import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/config_items.dart';
import 'package:share_plus/share_plus.dart';

class DataBottomSheet extends HookWidget {
  const DataBottomSheet({
    super.key,
    required this.index,
    required this.data,
    required this.type,
    required this.starred,
    required this.createdAt,
    required this.ref,
  });
  final int index;
  final String data;
  final String type;
  final bool starred;
  final String createdAt;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    String displayInfo;
    switch (type) {
      case historyTypeShareTxt:
        displayInfo = 'テキスト共有により追加';
        break;
      case historyTypeShareImg:
        displayInfo = '画像共有により追加';
        break;
      case historyTypeSelectImg:
        displayInfo = '画像選択により追加';
        break;
      case noData:
        displayInfo = noData;
        break;
      case 'null':
        displayInfo = noData;
        break;
      default:
        displayInfo = 'カメラスキャン ・ $type';
    }

    final currentStarred = useState(starred);

    return Container(
      height: 600,
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
          Container(
            alignment: Alignment.center,
            height: 88,
            margin: const EdgeInsets.only(top: 12),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(data),
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 4,
            endIndent: 4,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 42,
              ),
              Icon(
                Icons.straighten_rounded,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                '${data.length}文字',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 42,
              ),
              Icon(
                Icons.calendar_month_rounded,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                type == noData && createdAt != noData
                    ? '$createdAt (更新時刻)'
                    : createdAt,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 42,
              ),
              Icon(
                Icons.info_outline_rounded,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                type == noData && createdAt != noData
                    ? '上記は、アプリ更新時のデータ更新時刻'
                    : displayInfo,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            thickness: 1,
            indent: 4,
            endIndent: 4,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                switchStarred(index);
                currentStarred.value = !currentStarred.value;
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 52,
                  ),
                  Icon(
                    currentStarred.value
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentStarred.value ? 'お気に入りから削除' : 'お気に入りに追加',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(
                  ClipboardData(text: data),
                ).then((_) {
                  showBottomSnackBar(
                    context,
                    'クリップボードにコピーしました',
                    icon: Icons.library_add_check_rounded,
                  );
                });
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 52,
                  ),
                  Icon(
                    Icons.copy_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'クリップボードにコピー',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Share.share(data, subject: 'QR I/O の履歴共有');
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 52,
                  ),
                  Icon(
                    Icons.share_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '共有',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                ref.read(qrImageConfigProvider.notifier).editData(data: data);
                ConfigItems.updateTextFieldValue(data);
                if (tabController.index != 1) {
                  tabController.animateTo(1);
                }
                draggableScrollableController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 52,
                  ),
                  Icon(
                    Icons.edit_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'QRコードを作成',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                deleteHistoryData(index);
                showBottomSnackBar(
                  context,
                  '削除しました',
                  icon: Icons.done_rounded,
                  seconds: 5,
                  bottomSnackbarAction: SnackBarAction(
                    label: '元に戻す',
                    onPressed: () {
                      addHistoryData(
                        data,
                        [noData, 'null'].contains(type) ? null : type,
                        [noData, 'null'].contains(createdAt) ? null : createdAt,
                        index: index,
                        starred: currentStarred.value,
                      );
                    },
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
                    '削除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
