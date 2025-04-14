import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/the_nav_bar.dart';
import '../views/widgets/emergency_button.dart';
import '../../data/emergency_type_data_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helper.dart';
import './widgets/emergency_dialog.dart';
import '../../../../core/utils/assets.dart';

class AlertView extends StatefulWidget {
  const AlertView({super.key});

  @override
  State<AlertView> createState() => _AlertViewState();
}

class _AlertViewState extends State<AlertView> {
  EmergencyType? selectedEmergency;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48) / 3 - 8; // 3 buttons in a row

    return Scaffold(
      backgroundColor: kBackGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: SvgPicture.asset(
                          AssetsData.avatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Title
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Helper.getResponsiveFontSize(
                      context,
                      fontSize: 14,
                    ),
                    color: kTextDarkColor,
                  ),
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
                    const TextSpan(
                      text:
                          "Tap the Alert button to notify your guardians\ncontacts and relevant help centers. Select the type of emergency to provide more details.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Alert Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Handle alert button tap
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary700,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary700.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
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
              ),

              const SizedBox(height: 24),

              /// What's your emergency?
              Text(
                "What's your emergency?",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                  fontWeight: FontWeight.bold,
                  color: kTextDarkerColor,
                ),
              ),

              const SizedBox(height: 12),

              /// Emergency Buttons Grid
              Column(
                children: [
                  // First row with 3 buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        emergenciesInAlertPage
                            .take(3)
                            .map(
                              (type) => SizedBox(
                                width: buttonWidth,
                                child: EmergencyButton(
                                  type: type,
                                  isSelected: selectedEmergency == type,
                                  onTap: () {
                                    setState(() {
                                      selectedEmergency = type;
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Second row with 2 buttons + See More
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...emergenciesInAlertPage
                          .skip(3)
                          .take(2)
                          .map(
                            (type) => SizedBox(
                              width: buttonWidth,
                              child: EmergencyButton(
                                type: type,
                                isSelected: selectedEmergency == type,
                                onTap: () {
                                  setState(() {
                                    selectedEmergency = type;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                      SizedBox(
                        width: buttonWidth,
                        child: GestureDetector(
                          onTap:
                              () => showDialog(
                                context: context,
                                builder: (_) => const EmergencyDialog(),
                              ).then((selectedEmergency) {
                                if (selectedEmergency != null) {
                                  setState(() {
                                    this.selectedEmergency = selectedEmergency;
                                  });
                                }
                              }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "See More",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: kPrimary900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              /// Custom Bottom Navigation Bar
              const Center(child: CustomNavBar()),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
