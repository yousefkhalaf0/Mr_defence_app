import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/features/home/presentation/manager/cubit/emergency_cubit.dart';
import 'package:app/features/home/presentation/views/widgets/emergency_button.dart';

class SosView extends StatefulWidget {
  const SosView({super.key});
  @override
  State<SosView> createState() => _SosViewState();
}

class _SosViewState extends State<SosView> {
  @override
  Widget build(BuildContext context) {
    double buttonWidth = Helper.getResponsiveWidth(context, width: 206);
    double buttonHeight = Helper.getResponsiveHeight(context, height: 206);

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
                onPressed: () {
                  final emergency =
                      context.read<EmergencyCubit>().state.selectedEmergency;
                  if (emergency != null) {
                    // Handle sending the SOS
                    print('Sending SOS for: ${emergency.name}');
                  }
                },
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
}
