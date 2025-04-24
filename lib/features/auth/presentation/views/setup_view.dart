import 'package:app/core/utils/constants.dart';
import 'package:app/core/widgets/animated_popup_message.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/manager/profile_image_cubit/profile_image_cubit.dart';
import 'package:app/features/auth/presentation/manager/user_data_cubit/user_data_cubit.dart';
import 'package:app/features/auth/presentation/views/widgets/setup_view_body.dart';
import 'package:app/features/auth/presentation/views/widgets/user_data_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetUpView extends StatelessWidget {
  const SetUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserDataCubit()),
        BlocProvider(create: (context) => ProfileImageCubit()),
      ],
      child: const SetUpViewContent(),
    );
  }
}

class SetUpViewContent extends StatefulWidget {
  const SetUpViewContent({super.key});

  @override
  State<SetUpViewContent> createState() => _SetUpViewContentState();
}

class _SetUpViewContentState extends State<SetUpViewContent> {
  final _userDataFormKey = GlobalKey<UserDataFormState>();

  void _saveUserData() async {
    final formState = _userDataFormKey.currentState;

    if (formState != null && formState.validateForm()) {
      // Get user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      // Show loading state
      context.read<UserDataCubit>().emit(UserDataLoading());

      try {
        // Upload profile image if available
        final profileImageCubit = context.read<ProfileImageCubit>();
        String? profileImageUrl;

        if (profileImageCubit.state is ProfileImageLoaded) {
          profileImageUrl = await profileImageCubit.uploadProfileImage(
            user.uid,
          );
        }

        // Get form data
        final userData = formState.getFormData();

        // Add profile image URL to userData if available
        if (profileImageUrl != null) {
          userData['profileImage'] = profileImageUrl;
        }

        // Save user data
        await context.read<UserDataCubit>().saveUserData(userData);
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile setup complete!')),
          );
          // Navigate to next screen if needed
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else if (state is UserDataFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: kNeutral500,
          body: SafeArea(
            child: SetUpViewBody(userDataFormKey: _userDataFormKey),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          floatingActionButton: CustomSqircleButton(
            text: 'Complete',
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
