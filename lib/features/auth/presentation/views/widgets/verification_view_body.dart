import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/enums.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/views/widgets/otp_form.dart';
import 'package:app/features/auth/presentation/views/widgets/resend_code_text.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_description_text.dart';
import 'package:flutter/material.dart';

class VerificationViewBody extends StatelessWidget {
  const VerificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      child: Column(
        children: [
          const VerificationDescriptionText(),
          const OtpForm(),
          ResendCodeText(onResend: () {}),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: h * 0.079),
            child: CustomSqircleButton(
              text: 'Verify',
              onPressed: () {},
              btnColor: kTextDarkerColor,
              textColor: kTextLightColor,
            ),
          ),
        ],
      ),
    );
  }
}
