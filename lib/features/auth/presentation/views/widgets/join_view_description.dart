import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class JoinViewDescription extends StatelessWidget {
  const JoinViewDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Next we will check that you are the user of the indicated phone.',
        style: TextStyle(
          fontSize: Helper.getResponsiveFontSize(context, fontSize: 15),
          color: kNeutral300,
        ),
      ),
    );
  }
}
