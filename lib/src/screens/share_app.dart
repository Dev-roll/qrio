import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrio/src/qr_image_config.dart';
import 'package:qrio/src/utils.dart';
import 'package:qrio/src/widgets/custom_qr_image.dart';
import 'package:share_plus/share_plus.dart';

class ShareApp extends StatelessWidget {
  const ShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR I/O をシェア'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.android_rounded,
                        size: 32,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.75),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        'Android',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Google Play',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Share.share(
                              'https://play.google.com/store/apps/details?id=app.web.qrio');
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('共有'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                                text:
                                    'https://play.google.com/store/apps/details?id=app.web.qrio'),
                          ).then(
                            (_) {
                              showBottomSnackBar(
                                context,
                                'クリップボードにコピーしました',
                                icon: Icons.library_add_check_rounded,
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('リンクをコピー'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 4,
                ),
              ),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: ThemeData(
                    primaryColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: CustomQrImage(
                    qrImageConfig: QrImageConfig(
                      data:
                          'https://play.google.com/store/apps/details?id=app.web.qrio',
                      qrSeedColor: Theme.of(context).primaryColor,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.apple,
                        size: 32,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.75),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        'iOS',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'App Store',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Share.share(
                              'https://apps.apple.com/us/app/qr-i-o-qr-%E3%82%B3%E3%83%BC%E3%83%89-%E8%AA%AD%E3%81%BF%E5%8F%96%E3%82%8A-%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id1661431115');
                        },
                        icon: const Icon(CupertinoIcons.share),
                        label: const Text('共有'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                                text:
                                    'https://apps.apple.com/us/app/qr-i-o-qr-%E3%82%B3%E3%83%BC%E3%83%89-%E8%AA%AD%E3%81%BF%E5%8F%96%E3%82%8A-%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id1661431115'),
                          ).then(
                            (_) {
                              showBottomSnackBar(
                                context,
                                'クリップボードにコピーしました',
                                icon: Icons.library_add_check_rounded,
                              );
                            },
                          );
                        },
                        icon: const Icon(CupertinoIcons.link),
                        label: const Text('リンクをコピー'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 4,
                ),
              ),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: ThemeData(
                    primaryColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: CustomQrImage(
                    qrImageConfig: QrImageConfig(
                      data:
                          'https://apps.apple.com/us/app/qr-i-o-qr-%E3%82%B3%E3%83%BC%E3%83%89-%E8%AA%AD%E3%81%BF%E5%8F%96%E3%82%8A-%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id1661431115',
                      qrSeedColor: Theme.of(context).primaryColor,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
