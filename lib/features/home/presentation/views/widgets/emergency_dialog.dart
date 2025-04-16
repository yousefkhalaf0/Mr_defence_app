import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:flutter/material.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/core/utils/constants.dart';
import 'package:flutter_svg/svg.dart';

class EmergencyDialog extends StatefulWidget {
  const EmergencyDialog({super.key});

  @override
  State<EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  EmergencyType? selectedEmergency;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: Helper.getResponsiveWidth(context, width: 600),

        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: SvgPicture.asset(
                  AssetsData.backInShowDialog,
                  height: Helper.getResponsiveHeight(context, height: 42),
                  width: Helper.getResponsiveWidth(context, width: 42),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Text(
              "What's your emergency?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kNeutral500,
              ),
            ),

            const SizedBox(height: 16),

            // Emergency options
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,

              runSpacing: 8,
              children:
                  theWholeEmergencies.map((emergency) {
                    return EmergencyButton(
                      type: emergency,
                      isSelected: selectedEmergency == emergency,
                      onTap: () {
                        setState(() {
                          selectedEmergency = emergency;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed:
                    selectedEmergency == null
                        ? null
                        : () {
                          Navigator.pop(context, selectedEmergency);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTextRedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text("Ok", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
