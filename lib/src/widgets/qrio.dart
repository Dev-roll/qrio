import 'dart:async';
import 'dart:math';

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_center_focus_rounded),
          SizedBox(width: 8),
          Text('読み取り'),
          SizedBox(width: 4),
        ],
      ),
    ),
    const Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded),
          SizedBox(width: 8),
          Text('作成'),
          SizedBox(width: 4),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController()
      ..addListener(() {
        ref.read(qrioStateProvider.notifier).setTabOffset(pageController.page!);
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
    pageController.dispose();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrioStateProvider);
    final navBgColor =
        Theme.of(context).brightness == Brightness.dark ? black : white;
    final leftColor = Color.alphaBlend(
      Theme.of(context)
          .colorScheme
          .onBackground
          .withOpacity(0.5 * state.tabOffset),
      navBgColor,
    );
    final rightColor = Color.alphaBlend(
      Theme.of(context)
          .colorScheme
          .onBackground
          .withOpacity(0.5 * (1 - state.tabOffset)),
      navBgColor,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          PageView(
            controller: pageController,
            children: const [
              ScanCode(),
              Editor(),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset.zero,
                // offset: Offset((0.4 - state.tabOffset) * 110, 0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? black
                        : white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: leftCurve(state.tabOffset) * 128,
                        right: rightCurve(state.tabOffset) * 94,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: (() {
                                pageController.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_center_focus_rounded,
                                        color: leftColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      '読み取り',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: leftColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          GestureDetector(
                              onTap: (() {
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, color: rightColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      '作成',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: rightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ],
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
        ],
      ),
    );
  }

  double leftCurve(double x) {
    return 1 - cos(pi / 2 * x);
  }

  double rightCurve(double x) {
    return 1 - sin(pi / 2 * x);
  }
}
