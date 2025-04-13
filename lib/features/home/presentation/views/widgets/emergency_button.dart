import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/emergency_type_data_model.dart';
import '../../../../../core/utils/constants.dart';

class EmergencyButton extends StatefulWidget {
  final EmergencyType type;
  final VoidCallback onTap;

  const EmergencyButton({super.key, required this.type, required this.onTap});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() => isSelected = !isSelected);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? kTextRedColor : kNeutral500,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [BoxShadow(color: Colors.black26, blurRadius: 6)]
                  : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isSelected ? kNeutral500 : widget.type.backgroundColor,
              child: SvgPicture.asset(
                widget.type.iconPath,
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.type.name,
              style: TextStyle(
                color: isSelected ? kNeutral500 : kPrimary900,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
