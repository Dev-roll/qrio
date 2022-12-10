import 'package:flutter/material.dart';
import 'package:qrio/src/widgets/scan_code.dart';

class QRIO extends StatelessWidget {
  const QRIO({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ScanCode(),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.background,
        height: MediaQuery.of(context).size.height * 0.1 + 100,
      ),
    );
  }
}
