import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/enums.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/core/widgets/show_alert.dart';
import 'package:app/features/auth/presentation/manager/profile_image_cubit/profile_image_cubit.dart';
import 'package:app/features/auth/presentation/manager/user_data_cubit/user_data_cubit.dart';
import 'package:app/features/auth/presentation/views/widgets/setup_view_body.dart';
import 'package:app/features/auth/presentation/views/widgets/user_data_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SetUpView extends StatefulWidget {
  const SetUpView({super.key, this.isFromProfile = false});
  final bool isFromProfile;

  @override
  State<SetUpView> createState() => _SetUpViewState();
}

class _SetUpViewState extends State<SetUpView> {
  final _userDataFormKey = GlobalKey<UserDataFormState>();

  void _saveUserData() async {
    final formState = _userDataFormKey.currentState;

    if (formState != null && formState.validateForm()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showPopUpAlert(
          context: context,
          message: 'User not authenticated',
          icon: Icons.error,
          color: kError,
        );
        return;
      }

      context.read<UserDataCubit>().emit(UserDataLoading());

      try {
        final profileImageCubit = context.read<ProfileImageCubit>();
        String? profileImageUrl;

        if (profileImageCubit.state is ProfileImageLoaded) {
          profileImageUrl = await profileImageCubit.uploadProfileImage(
            user.uid,
          );
        }

        final userData = formState.getFormData();

        if (profileImageUrl != null) {
          userData['profileImage'] = profileImageUrl;
        }

        await context.read<UserDataCubit>().saveUserData(userData);

        if (!widget.isFromProfile) {
          await MyShared.setBoolean(key: MySharedKeys.setUp, value: true);
        }
      } catch (e) {
        context.read<UserDataCubit>().emit(UserDataFailure(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserDataCubit, UserDataState>(
      listener: (context, state) {
        if (state is UserDataSuccess) {
          showPopUpAlert(
            context: context,
            message: 'Profile setup complete!',
            icon: Icons.check_circle,
            color: kSuccess,
          );
          if (!widget.isFromProfile) {
            GoRouter.of(context).go(AppRouter.kHomeView);
          } else {
            GoRouter.of(context).pop();
          }
        } else if (state is UserDataFailure) {
          showPopUpAlert(
            context: context,
            message: 'Something went wrong!',
            icon: Icons.error_outline,
            color: kError,
          );
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: kNeutral500,
          body: SafeArea(
            child: SetUpViewBody(
              userDataFormKey: _userDataFormKey,
              isFromProfile: widget.isFromProfile,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          floatingActionButton: CustomSqircleButton(
            text: widget.isFromProfile ? 'Update Profile' : 'Complete',
            onPressed: state is UserDataLoading ? null : _saveUserData,
            btnColor: kTextDarkerColor,
            textColor: kTextLightColor,
            isLoading: state is UserDataLoading,
          ),
        );
      },
    );
  }
}
