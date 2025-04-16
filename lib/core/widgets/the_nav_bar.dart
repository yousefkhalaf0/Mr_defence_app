import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/constants.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Helper.getResponsiveHeight(context, height: 90),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(AssetsData.homeNavIcon, 0),
          _buildNavItem(AssetsData.sosNavIcon, 1),
          _buildNavItem(AssetsData.exploreNavIcon, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(String icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        height: Helper.getResponsiveHeight(context, height: 56),
        width: Helper.getResponsiveWidth(context, width: 56),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
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
