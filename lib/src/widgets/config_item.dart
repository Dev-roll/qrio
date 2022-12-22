import 'package:flutter/material.dart';
import 'package:qrio/src/widgets/icon_box.dart';

class ConfigItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(BuildContext context) onTapListener;
  final String? title;
  final bool? switchValue;
  final Function(bool value)? switchOnChangeHandler;

  const ConfigItem({
    required this.label,
    required this.icon,
    required this.onTapListener,
    this.title,
    this.switchValue,
    this.switchOnChangeHandler,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapListener(context),
      child: Row(
        children: <Widget>[
          IconBox(icon: icon),
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 16.0),
              alignment:
                  title != null ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          if (switchValue != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 8.0),
                alignment: Alignment.centerRight,
                child: Switch(
                  // This bool value toggles the switch.
                  value: switchValue!,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: switchOnChangeHandler,
                ),
              ),
            )
        ],
      ),
    );
  }
}
