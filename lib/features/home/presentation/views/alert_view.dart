import 'package:app/features/alert_request/presentation/manager/emergency_request_cubit/emergency_request_cubit.dart';
import 'package:app/features/alert_request/presentation/views/alert_request.dart';
import 'package:app/features/home/presentation/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_dialog.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';

class AlertView extends StatelessWidget {
  const AlertView({super.key});

  static Widget withBlocProvider() {
    return BlocProvider(
      create: (context) => EmergencyCubit(),
      child: const AlertView(),
    );
  }

  void _handleAlertPressed(BuildContext context) {
    final EmergencyType emergencyToUse =
        context.read<EmergencyCubit>().state.selectedEmergency ??
        defultEmergency;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => EmergencyRequestCubit(),
              child: EmergencyRequestView(emergencyType: emergencyToUse),
            ),
      ),
    );
    context.read<EmergencyCubit>().clearSelectedEmergency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Helper.getResponsiveWidth(
              context,
              width: Helper.getResponsiveWidth(context, width: 18),
            ),
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
                        SizedBox(
                          height: Helper.getResponsiveHeight(
                            context,
                            height: 9,
                          ),
                        ),
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
                        SizedBox(
                          height: Helper.getResponsiveHeight(
                            context,
                            height: 8,
                          ),
                        ),
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
                    height: Helper.getResponsiveHeight(context, height: 220),
                    width: Helper.getResponsiveWidth(context, width: 220),
                  ),
                  onPressed: () => _handleAlertPressed(context),
                ),
              ),
              const Spacer(),

              /// Selected Emergency Display
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

              /// What's your emergency?
              Text(
                "What's your emergency?",
                style: TextStyle(
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                  fontWeight: FontWeight.w800,
                  color: kTextDarkerColor,
                ),
              ),

              SizedBox(height: Helper.getResponsiveHeight(context, height: 12)),

              /// Emergency Buttons Grid
              BlocBuilder<EmergencyCubit, EmergencyState>(
                builder: (context, state) {
                  return Column(
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
                                    isSelected:
                                        state.selectedEmergency?.name ==
                                        type.name,
                                    onTap: () {
                                      context
                                          .read<EmergencyCubit>()
                                          .selectEmergency(type);
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(
                        height: Helper.getResponsiveHeight(context, height: 10),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...emergenciesInAlertPage
                              .skip(3)
                              .take(2)
                              .map(
                                (type) => EmergencyButton(
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
                          GestureDetector(
                            onTap: () {
                              showDialog<EmergencyType?>(
                                barrierColor: const Color(
                                  0xff141A1F,
                                ).withOpacity(0.78),
                                context: context,
                                builder:
                                    (_) => EmergencyDialog(
                                      initialEmergency:
                                          context
                                              .read<EmergencyCubit>()
                                              .state
                                              .selectedEmergency,
                                    ),
                              ).then((selectedEmergencyFromDialog) {
                                if (selectedEmergencyFromDialog != null) {
                                  context
                                      .read<EmergencyCubit>()
                                      .selectEmergency(
                                        selectedEmergencyFromDialog,
                                      );
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(56, 69, 90, 100),
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
      ),
    );
  }
}
