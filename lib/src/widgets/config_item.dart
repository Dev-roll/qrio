import 'package:flutter/material.dart';

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
          SizedBox(
            width: 48.0,
            height: 48.0,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24.0,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 16.0))
        ],
      ),
    );
  }
}
