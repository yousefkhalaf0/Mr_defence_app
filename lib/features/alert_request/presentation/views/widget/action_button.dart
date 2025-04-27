import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffCECECE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: Helper.getResponsiveWidth(context, width: 20),
              height: Helper.getResponsiveWidth(context, width: 20),
              colorFilter: const ColorFilter.mode(
                Color(0xFFFD5B68),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: Helper.getResponsiveWidth(context, width: 5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: Helper.getResponsiveWidth(context, width: 14),
                  ),
                ),
                SizedBox(
                  height: Helper.getResponsiveHeight(context, height: 2),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF7E7E7E),
                    fontWeight: FontWeight.w600,
                    fontSize: Helper.getResponsiveWidth(context, width: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
