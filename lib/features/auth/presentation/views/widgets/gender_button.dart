import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GenderButton extends StatelessWidget {
  const GenderButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.29,
        height: h * 0.068,
        decoration: BoxDecoration(
          color: isSelected ? kTextRedColor : kNeutral100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: Styles.textStyle14(
                context,
              ).copyWith(color: isSelected ? kNeutral100 : kPrimary500n800),
            ),
            SvgPicture.asset(icon, width: w * 0.08),
          ],
        ),
      ),
    );
  }
}
