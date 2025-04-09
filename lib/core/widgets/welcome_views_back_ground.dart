import 'package:app/core/utils/constants.dart';
import 'package:flutter/material.dart';

class WelcomeViewsBackGround extends StatelessWidget {
  const WelcomeViewsBackGround({super.key, required this.content});
  final Widget content;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kGradientColor1, kGradientColor2],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: content,
    );
  }
}
