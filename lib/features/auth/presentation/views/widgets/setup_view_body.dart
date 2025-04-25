import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/presentation/views/widgets/gender_container.dart';
import 'package:app/features/auth/presentation/views/widgets/profile_img_picker.dart';
import 'package:app/features/auth/presentation/views/widgets/profile_setup_app_bar.dart';
import 'package:app/features/auth/presentation/views/widgets/user_data_form.dart';
import 'package:flutter/material.dart';

class SetUpViewBody extends StatelessWidget {
  const SetUpViewBody({
    super.key,
    required this.userDataFormKey,
    this.isFromProfile = false,
  });
  final GlobalKey<UserDataFormState> userDataFormKey;
  final bool isFromProfile;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
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
          GenderContainer(
            onGenderSelected: (gender) {
              userDataFormKey.currentState?.setGender(gender);
            },
          ),
          UserDataForm(key: userDataFormKey, isFromProfile: isFromProfile),
          SizedBox(height: h * 0.13),
        ],
      ),
    );
  }
}
