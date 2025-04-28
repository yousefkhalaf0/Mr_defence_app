import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoCard extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showTextField;
  final TextEditingController? descriptionController;
  final ValueChanged<String>? onDescriptionChanged;
  final Color? backgroundColor;
  final Widget? iconWidget;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.backgroundColor,
    this.showTextField = false,
    this.descriptionController,
    this.onDescriptionChanged,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCECECE),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom icon widget or SVG icon
              iconWidget ??
                  Container(
                    width: Helper.getResponsiveWidth(context, width: 52),
                    height: Helper.getResponsiveHeight(context, height: 52),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        icon,
                        width: Helper.getResponsiveWidth(context, width: 30),
                        height: Helper.getResponsiveWidth(context, width: 30),
                        colorFilter:
                            showTextField
                                ? const ColorFilter.mode(
                                  Color.fromARGB(255, 0, 0, 0),
                                  BlendMode.srcIn,
                                )
                                : const ColorFilter.mode(
                                  Color(0xFFFD5B68),
                                  BlendMode.srcIn,
                                ),
                      ),
                    ),
                  ),
              showTextField
                  ? SizedBox(
                    width: Helper.getResponsiveWidth(context, width: 15),
                  )
                  : SizedBox(
                    width: Helper.getResponsiveWidth(context, width: 5),
                  ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF181818),
                      fontWeight: FontWeight.w600,
                      fontSize: Helper.getResponsiveWidth(context, width: 16),
                    ),
                  ),
                  SizedBox(
                    width: Helper.getResponsiveHeight(context, height: 8),
                  ),
                  SizedBox(
                    width: Helper.getResponsiveWidth(
                      context,
                      width: Helper.getResponsiveWidth(context, width: 250),
                    ),
                    child: Text(
                      subtitle.contains("notselected")
                          ? "Enter your emergency Discription"
                          : subtitle.length > 50
                          ? "${subtitle.substring(0, 50)}..."
                          : subtitle,

                      style: TextStyle(
                        color: const Color(0xFF7E7E7E),
                        fontWeight: FontWeight.w500,
                        fontSize: Helper.getResponsiveWidth(context, width: 14),
                      ),
                      softWrap: true,
                      maxLines: 5,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (showTextField)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 0),
              child: SizedBox(
                width: Helper.getResponsiveWidth(
                  context,
                  width: 300,
                ), // Adjust width as needed
                height: Helper.getResponsiveHeight(
                  context,
                  height: 45,
                ), // Adjust height as needed
                child: TextField(
                  style: TextStyle(
                    color: const Color(0xFF181818),
                    fontWeight: FontWeight.w500,
                    fontSize: Helper.getResponsiveWidth(context, width: 14),
                  ),
                  controller: descriptionController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Add more about . . .',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                  onChanged: onDescriptionChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
