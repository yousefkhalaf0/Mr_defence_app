import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';

class ProfileSetUpAppBar extends StatelessWidget {
  const ProfileSetUpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;

    return ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0.028 * h),
      title: Text(
        'Profile Setup',
        style: Styles.textStyle27(context).copyWith(color: kPrimary500n800),
      ),
      subtitle: Text(
        'Let’s complete your profile',
        style: Styles.textStyle12(context).copyWith(color: kNeutral600),
      ),
    );
  }
}
