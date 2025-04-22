import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileImgPicker extends StatelessWidget {
  const ProfileImgPicker({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.only(top: 0.01 * h, bottom: 0.02 * h),
      child: GestureDetector(
        onTap: () {},
        child: CircleAvatar(
          radius: 0.13 * w,
          backgroundColor: kNeutral100,
          child: SvgPicture.asset(AssetsData.uploadPicIcon, width: 0.1 * w),
        ),
      ),
    );
  }
}
