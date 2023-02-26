import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/widgets/icon_box.dart';

import '../app.dart';
import '../qr_image_config.dart';

class ConfigItem extends ConsumerWidget {
  final String? label;
  final String? title;
  final String? option;
  final bool? switchValue;
  final Function(bool value)? switchOnChangeHandler;
  final IconData icon;
  final Function(BuildContext context) onTapListener;

  const ConfigItem({
    this.label,
    this.title,
    this.option,
    this.switchValue,
    this.switchOnChangeHandler,
    required this.icon,
    required this.onTapListener,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

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
          if (label != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 16.0),
                // alignment: title != null
                //     ? Alignment.centerRight
                //     : Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (title == "QR コードの色")
                      Row(
                        children: [
                          Stack(
                            children: [
                              Icon(Icons.circle_rounded,
                                  color: qrImageConfig.qrSeedColor),
                              const Icon(
                                Icons.circle_outlined,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(width: 4.0),
                        ],
                      ),
                    Text(
                      label!,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
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
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> _) {
                      if (switchValue ?? false) {
                        return Icon(
                          Icons.dark_mode_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
