import 'package:app/features/auth/presentation/views/widgets/custom_otp_text_field.dart';
import 'package:flutter/material.dart';

class OtpForm extends StatelessWidget {
  const OtpForm({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      child: const Form(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomOtpTextField(),
            CustomOtpTextField(),
            CustomOtpTextField(),
            CustomOtpTextField(),
          ],
        ),
      ),
    );
  }
}
