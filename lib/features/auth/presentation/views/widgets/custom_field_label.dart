import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomFieldLabel extends StatelessWidget {
  const CustomFieldLabel({super.key, required this.labelText, this.icon});
  final String labelText;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.only(
        left: w * 0.02,
        top: h * 0.018,
        bottom: h * 0.009,
      ),
      child: Row(
        children: [
          if (icon != null && icon!.isNotEmpty)
            SvgPicture.asset(icon!, width: w * 0.04),
          SizedBox(width: w * 0.02),
          Text(
            labelText,
            style: Styles.textStyle14(
              context,
            ).copyWith(color: kTextDarkestColor),
          ),
        ],
      ),
    );
  }
}
