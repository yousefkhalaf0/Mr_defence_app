import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/presentation/views/widgets/gender_container.dart';
import 'package:app/features/auth/presentation/views/widgets/profile_img_picker.dart';
import 'package:app/features/auth/presentation/views/widgets/profile_setup_app_bar.dart';
import 'package:flutter/material.dart';

class SetUpViewBody extends StatelessWidget {
  const SetUpViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const ProfileSetUpAppBar(),
          Text(
            'Upload a profile picture (Optional)',
            style: Styles.textStyle12(context).copyWith(color: kNeutral600),
          ),
          const ProfileImgPicker(),
          const GenderContainer(),
        ],
      ),
    );
  }
}
