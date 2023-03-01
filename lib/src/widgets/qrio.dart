import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../screens/editor.dart';
import '../utils.dart';
import 'scan_code.dart';

class Qrio extends StatefulWidget {
  const Qrio({super.key});

  @override
  State<Qrio> createState() => _QrioState();
}

class _QrioState extends State<Qrio> with SingleTickerProviderStateMixin {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;
  String? _sharedText;
  final List<Tab> tabs = <Tab>[
    Tab(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
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
    Tab(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
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
        selectedIndex = tabController.index;
      });
    });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        debugPrint(
            "Shared:${_sharedFiles?.map((f) => f.path).join(",") ?? ""}");
        _sharedFiles?.forEach((file) async {
          final List<String?> data = await scanImg(file.path);
          for (var str in data) {
            if (str != null) {
              updateHistory(str);
            }
          }
        });
      });
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        debugPrint(
            "Shared:${_sharedFiles?.map((f) => f.path).join(",") ?? ""}");
        _sharedFiles?.forEach((file) async {
          final List<String?> data = await scanImg(file.path);
          for (var str in data) {
            if (str != null) {
              updateHistory(str);
            }
          }
        });
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        debugPrint("Shared: $_sharedText");
        updateHistory(_sharedText!);
      });
    }, onError: (err) {
      debugPrint("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
        debugPrint("Shared: $_sharedText");
        updateHistory(_sharedText!);
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
