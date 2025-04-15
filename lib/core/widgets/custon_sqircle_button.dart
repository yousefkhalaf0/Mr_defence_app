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
    this.disabledBtnColor = const Color(0xffE0E3E3),
    this.disabledTextColor = const Color(0xffB3B3B3),
  });
  final String? text;
  final Color? textColor;
  final Color disabledTextColor;
  final double fontSize;
  final Color? btnColor;
  final Color disabledBtnColor;
  final VoidCallback? onPressed;
  final double width;
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: textColor,
          disabledBackgroundColor: disabledBtnColor,
          disabledForegroundColor: disabledTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: h * 0.0173),
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
