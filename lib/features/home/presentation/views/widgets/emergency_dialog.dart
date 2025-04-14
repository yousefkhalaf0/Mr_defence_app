import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/emergency_type_data_model.dart';
import '../../../../../core/utils/constants.dart';

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kBackGroundColor,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "What's your emergency?",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kTextDarkerColor,
              ),
            ),

            const SizedBox(height: 16),

            // Emergency options
            Wrap(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: kTextDarkColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
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
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontFamily: 'Inter', color: Colors.white),
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
