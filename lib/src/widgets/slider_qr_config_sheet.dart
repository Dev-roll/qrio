import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/app.dart';
import 'package:qrio/src/constants.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/select_option.dart';

class SliderQrConfigSheet<T> extends ConsumerWidget {
  const SliderQrConfigSheet({
    required this.title,
    required this.options,
    required this.groupValue,
    required this.editConfigFunc,
    required this.ref,
    this.icon,
    super.key,
  });

  final String title;
  final List<SelectOption<T>> options;
  final int groupValue;
  final Function(int value) editConfigFunc;
  final WidgetRef ref;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return Container(
      height: MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              appBarHeight +
              qrCodeViewHeight +
              28),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: alphaBlend(
          Theme.of(context).colorScheme.primary.withOpacity(0.08),
          Theme.of(context).colorScheme.surface,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      icon,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.75),
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              Row(
                children: [
                  Text(
                    selectQrErrorCorrectLevelOptionGroup
                        .getLabelFromValue(qrImageConfig.errorCorrectLevel),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            indent: 4,
            endIndent: 4,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
          ),
          const SizedBox(height: 40),
          Slider(
            label: selectQrErrorCorrectLevelOptionGroup
                .getLabelFromValue(qrImageConfig.errorCorrectLevel),
            value: qrErrorCorrectLevelToIndex(qrImageConfig.errorCorrectLevel)
                .toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            onChanged: (value) {
              int i = value.toInt();
              editConfigFunc(QrErrorCorrectLevel.levels[i]);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
