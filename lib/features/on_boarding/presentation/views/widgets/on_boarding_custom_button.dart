import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class OnBoardingCustomButton extends StatelessWidget {
  const OnBoardingCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String? text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.9,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kTextLightColor,
          foregroundColor: kTextDarkerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Helper.getResponsiveFontSize(context, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
