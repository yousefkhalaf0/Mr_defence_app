import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_dialog.dart';
import 'package:app/core/utils/assets.dart';

class AlertView extends StatefulWidget {
  const AlertView({super.key});

  @override
  State<AlertView> createState() => _AlertViewState();
}

class _AlertViewState extends State<AlertView> {
  EmergencyType? selectedEmergency;

  @override
  Widget build(BuildContext context) {
    double buttonWidth = Helper.getResponsiveWidth(context, width: 206);
    double buttonHeight = Helper.getResponsiveHeight(context, height: 206);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: null, // Set leading to null to avoid default spacing
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsData.appLogoInHomepage,
              height: Helper.getResponsiveHeight(context, height: 47),
              width: Helper.getResponsiveWidth(context, width: 47),
            ),

            Text(
              "MR. DEFENCE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: kPrimary700.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          SvgPicture.asset(
            AssetsData.notificationWithCircle,

            height: Helper.getResponsiveHeight(context, height: 27),
            width: Helper.getResponsiveWidth(context, width: 27),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: SvgPicture.asset(AssetsData.avatar, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Helper.getResponsiveWidth(context, width: 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Row(
                children: [
                  SizedBox(
                    width: Helper.getResponsiveWidth(context, width: 250),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Need to report an incident?",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: Helper.getResponsiveFontSize(
                              context,
                              fontSize: 24,
                            ),
                            height: 1.2,
                            color: kPrimary900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          style: TextStyle(
                            height: 0,
                            fontWeight: FontWeight.normal,
                            color: kTextDarkerColor,
                            fontSize: Helper.getResponsiveFontSize(
                              context,
                              fontSize: 12,
                            ),
                          ),
                          "Tap the Alert button to notify your guardians contacts and relevant help centers. Select the type of emergency to provide more details.",
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    AssetsData.alertTextIllustration,
                    height: Helper.getResponsiveHeight(context, height: 128),
                    width: Helper.getResponsiveWidth(context, width: 95),
                  ),
                ],
              ),

              /// Alert Button
              Center(
                child: IconButton(
                  icon: SvgPicture.asset(
                    AssetsData.alertButton,
                    height: buttonHeight,
                    width: buttonWidth,
                  ),
                  onPressed: () {},
                ),
              ),

              SizedBox(height: Helper.getResponsiveHeight(context, height: 6)),

              /// What's your emergency?
              Text(
                "What's your emergency?",
                style: TextStyle(
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                  fontWeight: FontWeight.w800,
                  color: kTextDarkerColor,
                ),
              ),

              const SizedBox(height: 12),

              /// Emergency Buttons Grid
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  // First row with 3 buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        emergenciesInAlertPage
                            .take(3)
                            .map(
                              (type) => EmergencyButton(
                                type: type,
                                isSelected: selectedEmergency == type,
                                onTap: () {
                                  setState(() {
                                    selectedEmergency = type;
                                  });
                                },
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
                            (type) => EmergencyButton(
                              type: type,
                              isSelected: selectedEmergency == type,
                              onTap: () {
                                setState(() {
                                  selectedEmergency = type;
                                });
                              },
                            ),
                          ),

                      // .map(
                      //   (type) => SizedBox(
                      //     width: buttonWidth,
                      //     child: EmergencyButton(
                      //       type: type,
                      //       isSelected: selectedEmergency == type,
                      //       onTap: () {
                      //         setState(() {
                      //           selectedEmergency = type;
                      //         });
                      //       },
                      //     ),
                      //   ),
                      // ),
                      GestureDetector(
                        onTap:
                            () => showDialog(
                              barrierColor: const Color(
                                0xff141A1F,
                              ).withOpacity(0.78),
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
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(56, 69, 90, 100),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AssetsData.expandIcon,
                                height: Helper.getResponsiveHeight(
                                  context,
                                  height: 14,
                                ),
                                width: Helper.getResponsiveWidth(
                                  context,
                                  width: 14,
                                ),
                              ),
                              SizedBox(
                                width: Helper.getResponsiveWidth(
                                  context,
                                  width: 4,
                                ),
                              ),
                              Text(
                                "See More",
                                style: TextStyle(
                                  fontSize: Helper.getResponsiveWidth(
                                    context,
                                    width: 9,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: kPrimary700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              /// Custom Bottom Navigation Bar
              Center(child: CustomNavBar()),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
