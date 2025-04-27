import 'package:app/features/auth/presentation/views/widgets/custom_otp_text_field.dart';
import 'package:flutter/material.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({super.key, required this.controllers});

  final List<TextEditingController> controllers;

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(widget.controllers.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      child: Form(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < 6; i++)
              CustomOtpTextField(
                controller: widget.controllers[i],
                focusNode: focusNodes[i],
                previousFocusNode: i > 0 ? focusNodes[i - 1] : null,
              ),
          ],
        ),
      ),
    );
  }
}
