import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';
import '../utils.dart';
import 'config_item.dart';
import 'icon_box.dart';
import 'select_qr_background_color_dialog.dart';
import 'select_qr_data_module_shape_dialog.dart';
import 'select_qr_error_correct_level_dialog.dart';
import 'select_qr_eye_shape_dialog.dart';
import 'select_qr_foreground_color_dialog.dart';

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
            onTapListener: openDialogFactory(const SelectQrEyeShapeDialog()),
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.dataModuleShape,
                    selectQrDataModuleShapeOptions)
                .label,
            icon: Icons.apps_rounded,
            onTapListener:
                openDialogFactory(const SelectQrDataModuleShapeDialog()),
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.errorCorrectLevel,
                    selectQrErrorCorrectLevelOptions)
                .label,
            icon: Icons.check_circle_outline,
            onTapListener:
                openDialogFactory(const SelectQrErrorCorrectLevelDialog()),
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.backgroundColor, selectQrColorOptions)
                .label,
            icon: Icons.format_color_fill_rounded,
            onTapListener:
                openDialogFactory(const SelectQrBackgroundColorDialog()),
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.foregroundColor, selectQrColorOptions)
                .label,
            icon: Icons.border_color_rounded,
            onTapListener:
                openDialogFactory(const SelectQrForegroundColorDialog()),
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
