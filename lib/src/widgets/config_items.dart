import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../constants.dart';
import '../qr_image_config.dart';
import 'config_item.dart';
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

  void openSelectQrEyeShapeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SelectQrEyeShapeDialog(),
    );
  }

  void openSelectQrDataModuleShapeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SelectQrDataModuleShapeDialog(),
    );
  }

  void openSelectQrErrorCorrectLevelDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SelectQrErrorCorrectLevelDialog(),
    );
  }

  void openSelectQrBackgroundColorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SelectQrBackgroundColorDialog(),
    );
  }

  void openSelectQrForegroundColorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SelectQrForegroundColorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QrImageConfig qrImageConfig = ref.watch(qrImageConfigProvider);

    return Column(
      children: <Widget>[
        ...[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'リンク',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onChanged: ((value) {
              ref.read(qrImageConfigProvider.notifier).editData(data: value);
            }),
          ),
          // ConfigItem(
          //   label: '中央に画像を追加 (準備中)',
          //   icon: Icons.add_photo_alternate_rounded,
          //   onTapListener: ((context) {}),
          // ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.eyeShape, selectQrEyeShapeOptions)
                .label,
            icon: Icons.all_out_rounded,
            onTapListener: openSelectQrEyeShapeDialog,
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.dataModuleShape,
                    selectQrDataModuleShapeOptions)
                .label,
            icon: Icons.apps_rounded,
            onTapListener: openSelectQrDataModuleShapeDialog,
          ),
          ConfigItem(
            label: getOptionFromValue(qrImageConfig.errorCorrectLevel,
                    selectQrErrorCorrectLevelOptions)
                .label,
            icon: Icons.check_circle_outline,
            onTapListener: openSelectQrErrorCorrectLevelDialog,
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.backgroundColor, selectQrColorOptions)
                .label,
            icon: Icons.format_color_fill_rounded,
            onTapListener: openSelectQrBackgroundColorDialog,
          ),
          ConfigItem(
            label: getOptionFromValue(
                    qrImageConfig.foregroundColor, selectQrColorOptions)
                .label,
            icon: Icons.border_color_rounded,
            onTapListener: openSelectQrForegroundColorDialog,
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
