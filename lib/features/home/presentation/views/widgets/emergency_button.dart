import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/core/utils/constants.dart';

class EmergencyButton extends StatefulWidget {
  final EmergencyType type;
  final VoidCallback onTap;
  final bool isSelected;

  const EmergencyButton({
    super.key,
    required this.type,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? kTextRedColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              widget.isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Helper.getResponsiveWidth(context, width: 32),
              height: Helper.getResponsiveHeight(context, height: 32),
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? Colors.white
                        : widget.type.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  widget.type.iconPath,
                  height: Helper.getResponsiveHeight(context, height: 14),
                  width: Helper.getResponsiveWidth(context, width: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.type.name,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : kPrimary900,
                fontWeight: FontWeight.w500,
                fontSize: Helper.getResponsiveWidth(context, width: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
