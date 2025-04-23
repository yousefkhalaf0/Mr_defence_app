import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/home/presentation/manager/helper/get_location.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:permission_handler/permission_handler.dart';

class SosButtonPage extends StatefulWidget {
  const SosButtonPage({super.key});

  @override
  State<SosButtonPage> createState() => _SosButtonPageState();
}

class _SosButtonPageState extends State<SosButtonPage> {
  EmergencyType? _selectedEmergencyType;
  int _sosButtonPressCount = 0;
  bool _isSosButtonPressed = false;
  Position? _currentPosition;
  @override
  void initState() {
    super.initState();
    _setupLocationTracking();
  }

  void _setupLocationTracking() {
    getLocation(
      onLocationUpdate: (Position position) {
        setState(() {
          _currentPosition = position;
        });
        print(
          'Location updated in SOS page: ${position.latitude}, ${position.longitude}',
        );
      },
    );
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
                //  return const SizedBox.shrink();
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
            const SizedBox(height: 12),
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

            /// Custom Bottom Navigation Bar
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
      _isSosButtonPressed = true;
    });

    // Reset the visual feedback after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isSosButtonPressed = false;
        });
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
    // Check for permissions
    final locationPermission = await Permission.locationWhenInUse.request();
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    if (locationPermission != PermissionStatus.granted ||
        cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All permissions are required for emergency services'),
        ),
      );
      return;
    }

    // Use selected emergency type or default if none selected
    final EmergencyType emergencyType =
        context.read<EmergencyCubit>().state.selectedEmergency ??
        emergenciesInAlertPage.first;

    // Add current location to the navigation parameters
    final Map<String, dynamic> params = {
      'direction': CameraLensDirection.front,
      'emergencyType': emergencyType,
    };

    // Include current location if available
    if (_currentPosition != null) {
      params['latitude'] = _currentPosition!.latitude;
      params['longitude'] = _currentPosition!.longitude;
      params['accuracy'] = _currentPosition!.accuracy;
      params['timestamp'] = _currentPosition!.timestamp.toIso8601String();
    }
    print(_currentPosition!.latitude);
    // Navigate to the auto capture page with location data
    context.push(AppRouter.kAutoCapture, extra: params);
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
