import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/screens/editor.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/scan_code.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Qrio extends ConsumerStatefulWidget {
  const Qrio({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QrioState();
}

class _QrioState extends ConsumerState<Qrio>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;
  String? _sharedText;
  final List<Tab> tabs = <Tab>[
    const Tab(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
          ),
          Icon(Icons.filter_center_focus_rounded),
          SizedBox(
            width: 8,
          ),
          Text('読み取り'),
          SizedBox(
            width: 8,
          ),
        ],
      ),
    ),
    const Tab(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
          ),
          Icon(Icons.edit_rounded),
          SizedBox(
            width: 8,
          ),
          Text('作成'),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {
        ref.watch(selectedIndexProvider.notifier).state = tabController.index;
        // selectedIndex = tabController.index;
      });
    });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles = value;
        debugPrint(
            "Shared:${_sharedFiles?.map((f) => f.path).join(",") ?? ""}");
        _sharedFiles?.forEach((file) async {
          final List<String?> data = await scanImg(file.path);
          for (var str in data) {
            if (str != null) {
              await addHistoryData(
                  str, historyTypeShareImg, DateTime.now().toString());
            }
          }
        });
      });
    }, onError: (err) {
      debugPrint('getIntentDataStream error: $err');
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles = value;
        debugPrint(
            "Shared:${_sharedFiles?.map((f) => f.path).join(",") ?? ""}");
        _sharedFiles?.forEach((file) async {
          final List<String?> data = await scanImg(file.path);
          for (var str in data) {
            if (str != null) {
              await addHistoryData(
                  str, historyTypeShareImg, DateTime.now().toString());
            }
          }
        });
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((value) {
      setState(() {
        _sharedText = value;
        debugPrint('Shared: $_sharedText');
        addHistoryData(
            _sharedText!, historyTypeShareTxt, DateTime.now().toString());
      });
    }, onError: (err) {
      debugPrint('getLinkStream error: $err');
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {
      setState(() {
        _sharedText = value;
        debugPrint('Shared: $_sharedText');
        addHistoryData(
            _sharedText!, historyTypeShareTxt, DateTime.now().toString());
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: const [
          ScanCode(),
          Editor(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: TabBar(
                tabs: tabs,
                controller: tabController,
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context).colorScheme.primary,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: const EdgeInsets.fromLTRB(-8, 0, -8, 0),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height *
                    defaultSheetHeight(context) +
                10,
          ),
        ],
      ),
    );
  }
}
