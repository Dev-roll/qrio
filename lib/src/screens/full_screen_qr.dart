import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qrio/src/widgets/custom_qr_image.dart';

class FullScreenQr extends HookWidget {
  const FullScreenQr({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    final animation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ConstantTween<double>(0.0),
          weight: 2,
        ),
      ],
    ).animate(animationController);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                return Opacity(
                  opacity: animation.value,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                );
              }),
          Container(
            alignment: Alignment.center,
            child: const CustomQrImage(),
          ),
        ],
      ),
    );
  }
}
