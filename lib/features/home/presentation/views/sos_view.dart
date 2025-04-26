// sos_button_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/home/presentation/manager/sos_request_cubit/sos_request_cubit.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';

class SosButtonPage extends StatefulWidget {
  const SosButtonPage({super.key});

  @override
  State<SosButtonPage> createState() => _SosButtonPageState();
}

class _SosButtonPageState extends State<SosButtonPage> {
  int _sosButtonPressCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize location tracking via RequestCubit
    context.read<RequestCubit>().initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Helper.getResponsiveWidth(context, width: 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: Helper.getResponsiveHeight(context, height: 9)),
            Row(
              children: [
                SizedBox(
                  width: Helper.getResponsiveWidth(context, width: 250),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Are you in an emergency?",
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
                        "Press the SOS button, your live location will be shared wih the nearest help centre and your emergency contacts will be notified.",
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  AssetsData.sosTextIllustration,
                  height: Helper.getResponsiveHeight(context, height: 128),
                  width: Helper.getResponsiveWidth(context, width: 95),
                ),
              ],
            ),
            Center(
              child: IconButton(
                icon: SvgPicture.asset(
                  AssetsData.sosButton,
                  height: Helper.getResponsiveHeight(context, height: 220),
                  width: Helper.getResponsiveWidth(context, width: 220),
                ),
                onPressed: () => _handleSosButtonPress(),
              ),
            ),
            const Spacer(),
            BlocBuilder<EmergencyCubit, EmergencyState>(
              builder: (context, state) {
                if (state.selectedEmergency?.name != null) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: Helper.getResponsiveHeight(context, height: 0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimary50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                state.selectedEmergency!.iconPath,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: Helper.getResponsiveWidth(
                                  context,
                                  width: 8,
                                ),
                              ),
                              Text(
                                state.selectedEmergency!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: kPrimary900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            context
                                .read<EmergencyCubit>()
                                .clearSelectedEmergency();
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),

            Text(
              "What's your emergency?",
              style: TextStyle(
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                fontWeight: FontWeight.w800,
                color: kTextDarkerColor,
              ),
            ),
            SizedBox(height: Helper.getResponsiveHeight(context, height: 12)),
            BlocBuilder<EmergencyCubit, EmergencyState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // First row with 3 buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          emergenciesInSosPage
                              .take(3)
                              .map(
                                (type) => Padding(
                                  padding: EdgeInsets.only(
                                    right: Helper.getResponsiveWidth(
                                      context,
                                      width: 8,
                                    ),
                                  ),
                                  child: EmergencyButton(
                                    type: type,
                                    isSelected:
                                        state.selectedEmergency?.name ==
                                        type.name,
                                    onTap: () {
                                      context
                                          .read<EmergencyCubit>()
                                          .selectEmergency(type);
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(
                      height: Helper.getResponsiveHeight(context, height: 10),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...emergenciesInSosPage
                            .skip(3)
                            .take(2)
                            .map(
                              (type) => EmergencyButton(
                                type: type,
                                isSelected:
                                    state.selectedEmergency?.name == type.name,
                                onTap: () {
                                  context
                                      .read<EmergencyCubit>()
                                      .selectEmergency(type);
                                },
                              ),
                            ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            const Center(child: CustomNavBar()),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _handleSosButtonPress() {
    setState(() {
      _sosButtonPressCount++;
    });

    // Reset the visual feedback after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {});
      }
    });

    // If button pressed 3 times, start emergency flow
    if (_sosButtonPressCount >= 3) {
      _startEmergencyFlow();
      // Reset count
      _sosButtonPressCount = 0;
    }
  }

  Future<void> _startEmergencyFlow() async {
    final requestCubit = context.read<RequestCubit>();
    final emergencyCubit = context.read<EmergencyCubit>();
    final defultEmergency = EmergencyType(
      name: 'notSelected',
      iconPath: AssetsData.customAlertType,
      backgroundColor: const Color(0xffC4912A),
    );
    // Get selected emergency type or use default
    final EmergencyType emergencyType =
        emergencyCubit.state.selectedEmergency ?? defultEmergency;
    final String requestType =
        context.read<EmergencyCubit>().state.currentPageIndex == 1
            ? "SOS"
            : "ALERT";
    // Set emergency type in the RequestCubit
    requestCubit.setEmergencyType(emergencyType);
    requestCubit.setRequestType(requestType);

    // Start the SOS request process which handles permissions and navigation
    final success = await requestCubit.startSosRequest(context);

    if (success) {
      // Navigate to the camera capture screen
      context.push(
        AppRouter.kAutoCapture,
        extra: {
          'direction': CameraLensDirection.front,
          'emergencyType': emergencyType,
          'requestType': requestType,
        },
      );
    }
  }
}
