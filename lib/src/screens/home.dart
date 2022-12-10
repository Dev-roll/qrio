import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/widgets/scan_code.dart';

import '../widgets/default_popup_menu.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR I/O'),
        actions: const <Widget>[
          DefaultPopupMenu(),
        ],
      ),
      body: const SafeArea(
        child: ScanCode(),
      ),
    );
  }
}
