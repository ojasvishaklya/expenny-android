import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String animationName;
  final double size;
  const LoadingWidget({Key? key, required this.animationName, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
          ''
          'animations/$animationName.json',
          height: size,
          repeat: true,
          reverse: false,
          fit: BoxFit.contain),
    );
  }
}
