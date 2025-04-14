import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/emergency_type_data_model.dart';
import '../../../../../core/utils/constants.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
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
                  height: 20,
                  width: 20,
                  color: widget.isSelected ? kTextRedColor : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.type.name,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : kPrimary900,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
