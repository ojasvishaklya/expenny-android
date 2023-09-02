import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String animationName;
  const LoadingWidget({Key? key, required this.animationName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
          ''
          'animations/$animationName.json',
          height: 200,
          repeat: true,
          reverse: false,
          fit: BoxFit.contain),
    );
  }
}
