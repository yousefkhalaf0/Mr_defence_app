import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class CustomSqircleButton extends StatelessWidget {
  const CustomSqircleButton({
    super.key,
    this.width = 0.9,
    required this.text,
    required this.onPressed,
    required this.btnColor,
    required this.textColor,
    this.fontSize = 20,
  });
  final String? text;
  final Color? textColor;
  final double fontSize;
  final Color? btnColor;
  final VoidCallback? onPressed;
  final double width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: textColor,
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
              fontSize: Helper.getResponsiveFontSize(
                context,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
