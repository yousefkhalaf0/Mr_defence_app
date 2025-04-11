import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class OnBoardingAppBar extends StatelessWidget {
  const OnBoardingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          'skip',
          style: TextStyle(
            color: kNeutral50,
            fontSize: Helper.getResponsiveFontSize(context, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
