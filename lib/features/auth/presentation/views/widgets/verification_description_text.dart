import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';

class VerificationDescriptionText extends StatelessWidget {
  const VerificationDescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(top: h * 0.037, bottom: h * 0.076),
      child: SizedBox(
        width: w * 0.6,
        child: Text(
          'Enter the verification code we’ve sent to your phone number',
          style: Styles.textStyle12(context).copyWith(color: kNeutral600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
