import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ResendCodeText extends StatelessWidget {
  const ResendCodeText({super.key, required this.onResend});

  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: EdgeInsets.only(top: h * 0.018),
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          text: 'Didn’t receive the code? ',
          style: Styles.textStyle12(context).copyWith(color: kNeutral600),
          children: [
            TextSpan(
              text: 'Resend',
              style: Styles.textStyle12(
                context,
              ).copyWith(color: kEmergency300, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()..onTap = onResend,
            ),
          ],
        ),
      ),
    );
  }
}
