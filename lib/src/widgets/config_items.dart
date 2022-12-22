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
          // ConfigItem(
          //   label: '中央に画像を追加',
          //   icon: Icons.add_photo_alternate_rounded,
          //   onTapListener: ((context) {}),
          // ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.eyeShape, selectQrEyeShapeOptions)
                .label,
            icon: Icons.all_out_rounded,
            onTapListener: openDialogFactory(SelectQrConfigDialog<QrEyeShape>(
              title: "EyeShape の選択",
              options: selectQrEyeShapeOptions,
              editConfigFunc: (QrEyeShape? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editEyeShape(eyeShape: value!);
              },
              groupValue: qrImageConfig.eyeShape,
            )),
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.dataModuleShape,
                    selectQrDataModuleShapeOptions)
                .label,
            icon: Icons.apps_rounded,
            onTapListener:
                openDialogFactory(SelectQrConfigDialog<QrDataModuleShape>(
              title: "DataModuleShape の選択",
              options: selectQrDataModuleShapeOptions,
              editConfigFunc: (QrDataModuleShape? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editDataModuleShape(dataModuleShape: value!);
              },
              groupValue: qrImageConfig.dataModuleShape,
            )),
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.errorCorrectLevel,
                    selectQrErrorCorrectLevelOptions)
                .label,
            icon: Icons.check_circle_outline,
            onTapListener: openDialogFactory(SelectQrConfigDialog<int>(
              title: "ErrorCorrectLevel の選択",
              options: selectQrErrorCorrectLevelOptions,
              editConfigFunc: (int? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editErrorCorrectLevel(errorCorrectLevel: value!);
              },
              groupValue: qrImageConfig.errorCorrectLevel,
            )),
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.backgroundColor, selectQrColorOptions)
                .label,
            icon: Icons.format_color_fill_rounded,
            onTapListener: openDialogFactory(SelectQrConfigDialog<Color>(
              title: "背景色の選択",
              options: selectQrColorOptions,
              editConfigFunc: (Color? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editBackgroundColor(backgroundColor: value!);
              },
              groupValue: qrImageConfig.backgroundColor,
            )),
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.foregroundColor, selectQrColorOptions)
                .label,
            icon: Icons.border_color_rounded,
            onTapListener: openDialogFactory(SelectQrConfigDialog<Color>(
              title: "QRコードの色の選択",
              options: selectQrColorOptions,
              editConfigFunc: (Color? value) {
                ref
                    .read(qrImageConfigProvider.notifier)
                    .editForegroundColor(foregroundColor: value!);
              },
              groupValue: qrImageConfig.foregroundColor,
            )),
          ),
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
