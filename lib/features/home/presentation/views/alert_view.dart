import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/the_nav_bar.dart';
import '../views/widgets/emergency_button.dart';
import '../../data/emergency_type_data_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helper.dart';
import './widgets/emergency_dialog.dart';
import '../../../../core/utils/assets.dart';

class AlertView extends StatelessWidget {
  AlertView({super.key});
  final List<EmergencyType> emergencies = emergenciesInAlertPage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              /// App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsData.appLogoInHomepage,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "MR. DEFENCE",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: Helper.getResponsiveFontSize(
                            context,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none, color: kPrimary900),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Title
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: DefaultTextStyle.of(
                    context,
                  ).style.copyWith(fontFamily: 'Inter'),
                  children: [
                    TextSpan(
                      text: "Need to report an incident?\n",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Helper.getResponsiveFontSize(
                          context,
                          fontSize: 20,
                        ),
                        color: kTextDarkerColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          "Tap the Alert button to notify your\n"
                          "guardians and help centers.",
                      style: TextStyle(
                        fontSize: Helper.getResponsiveFontSize(
                          context,
                          fontSize: 14,
                        ),
                        color: kTextDarkColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Alert Button
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, kPrimary700],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Alert',
                      style: TextStyle(
                        fontSize: Helper.getResponsiveFontSize(
                          context,
                          fontSize: 22,
                        ),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// What's your emergency?
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Whats your emergency?",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Helper.getResponsiveFontSize(
                      context,
                      fontSize: 16,
                    ),
                    fontWeight: FontWeight.bold,
                    color: kTextDarkerColor,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Emergency Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...emergenciesInAlertPage
                      .take(5)
                      .map((e) => EmergencyButton(type: e, onTap: () {})),
                  GestureDetector(
                    onTap:
                        () => showDialog(
                          context: context,
                          builder: (_) => const EmergencyDialog(),
                        ).then((selectedEmergency) {
                          if (selectedEmergency != null) {
                            // Handle the selected emergency
                            print(
                              "Selected emergency: ${selectedEmergency.name}",
                            );
                          }
                        }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kNeutral500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("See More"),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Custom Bottom Navigation Bar
              const CustomNavBar(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
