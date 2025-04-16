import 'package:app/features/auth/presentation/views/widgets/custom_otp_text_field.dart';
import 'package:flutter/material.dart';

class OtpFormKeys {
  static final formKey = GlobalKey<OtpFormState>();
}

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => OtpFormState();
}

class OtpFormState extends State<OtpForm> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  final _pin3 = TextEditingController();
  final _pin4 = TextEditingController();

  String getOtp() {
    return _pin1.text + _pin2.text + _pin3.text + _pin4.text;
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    _pin3.dispose();
    _pin4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      child: Form(
        key: OtpFormKeys.formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomOtpTextField(controller: _pin1, nextFocus: _pin2),
            CustomOtpTextField(controller: _pin2, nextFocus: _pin3),
            CustomOtpTextField(controller: _pin3, nextFocus: _pin4),
            CustomOtpTextField(controller: _pin4, nextFocus: null),
          ],
        ),
      ),
    );
  }
}
