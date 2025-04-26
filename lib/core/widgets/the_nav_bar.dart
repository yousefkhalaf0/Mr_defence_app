import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/utils/constants.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Helper.getResponsiveHeight(context, height: 80),
      width: Helper.getResponsiveWidth(context, width: 243),
      decoration: BoxDecoration(
        color: kPrimary700,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BlocBuilder<EmergencyCubit, EmergencyState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                AssetsData.homeNavIcon,
                0,
                state.currentPageIndex,
              ),
              _buildNavItem(
                context,
                AssetsData.sosNavIcon,
                1,
                state.currentPageIndex,
              ),
              _buildNavItem(
                context,
                AssetsData.messages,
                2,
                state.currentPageIndex,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String icon,
    int index,
    int currentIndex,
  ) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<EmergencyCubit>().changePage(index);

        context.read<EmergencyCubit>().clearSelectedEmergency();
      },

      child: Container(
        height: Helper.getResponsiveHeight(context, height: 56),
        width: Helper.getResponsiveWidth(context, width: 56),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    Helper.getResponsiveWidth(context, width: 150),
                  ),
                )
                : null,
        child: Center(
          child: SvgPicture.asset(
            icon,
            height: Helper.getResponsiveHeight(context, height: 23),
            width: Helper.getResponsiveWidth(context, width: 23),
            color: isSelected ? const Color(0xFFF36060) : null,
          ),
        ),
      ),
    );
  }
}
