import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/features/auth/presentation/views/widgets/gender_button.dart';
import 'package:flutter/material.dart';

class GenderContainer extends StatelessWidget {
  const GenderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 6),
      width: w * 0.66,
      height: h * 0.068, //may cause a problem
      decoration: BoxDecoration(
        color: kPrimary50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GenderButton(icon: AssetsData.maleIcon, title: 'Male', onTap: () {}),
          GenderButton(
            icon: AssetsData.femaleIcon,
            title: 'Female',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
