import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class AppNameText extends StatelessWidget {
  const AppNameText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'MR. DEFENCE',
      style: TextStyle(
        fontSize: Helper.getResponsiveFontSize(context, fontSize: 40),
        fontWeight: FontWeight.w900,
        color: kTextLightColor,
        shadows: [
          Shadow(
            color: Color.fromRGBO(0, 0, 0, 0.9),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
