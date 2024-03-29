import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/icon_box.dart';

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
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Row(
          children: <Widget>[
            IconBox(icon: icon),
            const SizedBox(width: 12),
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (label != null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (title == 'QR コードの色')
                        Row(
                          children: [
                            Stack(
                              children: [
                                Icon(
                                  Icons.circle_rounded,
                                  color: qrImageConfig.qrSeedColor,
                                ),
                                Icon(
                                  Icons.circle_outlined,
                                  color: alphaBlend(
                                    const Color(0xa0ffffff),
                                    qrImageConfig.qrSeedColor,
                                  ),
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
                  alignment: Alignment.centerRight,
                  child: Switch(
                    // This bool value toggles the switch.
                    value: switchValue!,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: switchOnChangeHandler,
                    thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (_) {
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
      ),
    );
  }
}
