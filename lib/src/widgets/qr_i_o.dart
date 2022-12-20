import 'package:flutter/material.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/screens/editor.dart';
import 'package:qrio/src/widgets/scan_code.dart';

class QRIO extends StatefulWidget {
  const QRIO({super.key});

  @override
  State<QRIO> createState() => _QRIOState();
}

class _QRIOState extends State<QRIO> with SingleTickerProviderStateMixin {
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          ScanCode(),
          Editor(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 16,
          ),
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              tabs: tabs,
              controller: _tabController,
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
          SizedBox(
            height: MediaQuery.of(context).size.height * defaultSheetHeight - 8,
          ),
        ],
      ),
    );
  }
}
