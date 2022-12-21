import 'package:flutter/material.dart';
import 'package:qrio/src/widgets/icon_box.dart';

class ConfigItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(BuildContext context) onTapListener;

  const ConfigItem({
    required this.label,
    required this.icon,
    required this.onTapListener,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapListener(context),
      child: Row(
        children: <Widget>[
          IconBox(icon: icon),
          Text(label, style: const TextStyle(fontSize: 16.0))
        ],
      ),
    );
  }
}
