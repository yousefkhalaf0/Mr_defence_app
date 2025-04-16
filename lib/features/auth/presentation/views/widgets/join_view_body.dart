import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/manager/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_phone_text_field.dart';
import 'package:app/features/auth/presentation/views/widgets/join_view_description.dart';
import 'package:app/features/auth/presentation/views/widgets/join_view_title.dart';
import 'package:app/features/auth/presentation/views/widgets/phone_text_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class JoinViewBody extends StatefulWidget {
  const JoinViewBody({super.key});

  @override
  State<JoinViewBody> createState() => _JoinViewBodyState();
}

class _JoinViewBodyState extends State<JoinViewBody> {
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listener: (context, state) {
        if (state is PhoneAuthCodeSent) {
          context.push(
            AppRouter.kVervificationView,
            extra: {
              'phone': _phoneNumber,
              'verificationId': state.verificationId,
            },
          );
        } else if (state is PhoneAuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PhoneAuthSuccess) {
          context.go(AppRouter.kHomeView);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: SingleChildScrollView(
          child: SizedBox(
            height: h,
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/join_view_img.svg'),
                SizedBox(height: h * 0.073),
                const JoinViewTitle(),
                SizedBox(height: h * 0.04),
                const JoinViewDescription(),
                SizedBox(height: h * 0.05),
                const PhoneTextFieldLabel(),
                SizedBox(height: h * 0.01),
                CustomPhoneTextField(
                  onNumberChanged: (number) {
                    setState(() {
                      _phoneNumber = number;
                    });
                  },
                ),
                SizedBox(height: h * 0.075),
                BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
                  builder: (context, state) {
                    return CustomSqircleButton(
                      text: 'Get code by SMS',
                      onPressed:
                          state is PhoneAuthLoading
                              ? null
                              : () {
                                if (_phoneNumber.isNotEmpty &&
                                    _phoneNumber.startsWith('+')) {
                                  context
                                      .read<PhoneAuthCubit>()
                                      .verifyPhoneNumber(_phoneNumber);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid phone number',
                                      ),
                                    ),
                                  );
                                }
                              },
                      btnColor: kTextDarkerColor,
                      textColor: kTextLightColor,
                      isLoading: state is PhoneAuthLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
