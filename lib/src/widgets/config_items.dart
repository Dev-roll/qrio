import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';
import '../utils.dart';
import 'config_item.dart';
import 'icon_box.dart';
import 'select_qr_config_dialog.dart';

class ConfigItems extends ConsumerWidget {
  const ConfigItems({super.key});

  static final TextEditingController _controller = TextEditingController();

  static void updateTextFieldValue(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return Column(
      children: <Widget>[
        ...[
          Row(
            children: [
              const IconBox(icon: Icons.link_rounded),
              Flexible(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'リンク',
                    border: InputBorder.none,
                  ),
                  onChanged: ((value) {
                    ref
                        .read(qrImageConfigProvider.notifier)
                        .editData(data: value);
                  }),
                ),
              ),
            ],
          ),
          ConfigItem(
            title: selectQrEyeShapeOptionGroup.title,
            label: selectQrEyeShapeOptionGroup
                .getLabelFromValue(qrImageConfig.eyeShape),
            icon: selectQrEyeShapeOptionGroup.icon!,
            onTapListener: openDialogFactory(SelectQrConfigDialog<QrEyeShape>(
              title: selectQrEyeShapeOptionGroup.title,
              options: selectQrEyeShapeOptionGroup.options,
              editConfigFunc: (QrEyeShape? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editEyeShape(eyeShape: value!);
              },
              groupValue: qrImageConfig.eyeShape,
            )),
          ),
          ConfigItem(
            title: selectQrDataModuleShapeOptionGroup.title,
            label: selectQrDataModuleShapeOptionGroup
                .getLabelFromValue(qrImageConfig.dataModuleShape),
            icon: selectQrDataModuleShapeOptionGroup.icon!,
            onTapListener:
                openDialogFactory(SelectQrConfigDialog<QrDataModuleShape>(
              title: selectQrDataModuleShapeOptionGroup.title,
              options: selectQrDataModuleShapeOptionGroup.options,
              editConfigFunc: (QrDataModuleShape? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editDataModuleShape(dataModuleShape: value!);
              },
              groupValue: qrImageConfig.dataModuleShape,
            )),
          ),
          ConfigItem(
            title: selectQrErrorCorrectLevelOptionGroup.title,
            label: selectQrErrorCorrectLevelOptionGroup
                .getLabelFromValue(qrImageConfig.errorCorrectLevel),
            icon: selectQrErrorCorrectLevelOptionGroup.icon!,
            onTapListener: openDialogFactory(SelectQrConfigDialog<int>(
              title: selectQrErrorCorrectLevelOptionGroup.title,
              options: selectQrErrorCorrectLevelOptionGroup.options,
              editConfigFunc: (int? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editErrorCorrectLevel(errorCorrectLevel: value!);
              },
              groupValue: qrImageConfig.errorCorrectLevel,
            )),
          ),
          ConfigItem(
            title: selectQrSeedColorOptionGroup.title,
            label: selectQrSeedColorOptionGroup
                .getLabelFromValue(qrImageConfig.qrSeedColor),
            icon: selectQrSeedColorOptionGroup.icon!,
            onTapListener: openDialogFactory(SelectQrConfigDialog<Color>(
              title: selectQrSeedColorOptionGroup.title,
              options: selectQrSeedColorOptionGroup.options,
              editConfigFunc: (Color? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editQrSeedColor(qrSeedColor: value!);
              },
              groupValue: qrImageConfig.qrSeedColor,
            )),
          ),
          ConfigItem(
            label: '色を反転する',
            icon: Icons.swap_horiz_rounded,
            onTapListener: (context) =>
                ref.read(qrImageConfigProvider.notifier).toggleIsReversed(),
            switchValue: qrImageConfig.isReversed,
            switchOnChangeHandler: (value) {
              ref.read(qrImageConfigProvider.notifier).toggleIsReversed();
            },
          )
        ].expand(
          (widget) => [
            widget,
            Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            )
          ],
        )
      ],
    );
  }
}
