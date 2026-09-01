import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String animationName;
  final double size;
  const LoadingWidget({
    super.key,
    required this.animationName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return TickerMode(
      enabled: !animationsDisabled,
      child: Center(
        child: Lottie.asset(
          'animations/$animationName.json',
          height: size,
          repeat: true,
          reverse: false,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
