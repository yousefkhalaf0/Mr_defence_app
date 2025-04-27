import 'package:app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpTextField extends StatelessWidget {
  const CustomOtpTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.previousFocusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? previousFocusNode;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: w * 0.12,
      height: h * 0.07,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        maxLength: 1,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && previousFocusNode != null) {
            previousFocusNode!.requestFocus();
          }
        },
        onSaved: (pin1) {},
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: '_',
          hintStyle: TextStyle(color: kNeutral700),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: kNeutral300),
          ),
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
