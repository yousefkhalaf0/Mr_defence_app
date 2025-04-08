import 'package:app/core/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            blurRadius: 45,
            offset: Offset(10, 5),
            spreadRadius: -55,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: SvgPicture.asset(AssetsData.appLogo),
      ),
    );
  }
}
