import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/core/widgets/show_alert.dart';
import 'package:app/features/auth/presentation/manager/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:app/features/auth/presentation/views/widgets/otp_form.dart';
import 'package:app/features/auth/presentation/views/widgets/resend_code_text.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_description_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerificationViewBody extends StatelessWidget {
  const VerificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    final phoneAuthCubit = BlocProvider.of<PhoneAuthCubit>(context);
    final otpController = List.generate(6, (index) => TextEditingController());

    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listener: (context, state) {
        if (state is PhoneAuthVerified) {
          GoRouter.of(context).go(AppRouter.kSetUpView);
        } else if (state is PhoneAuthError) {
          showPopUpAlert(
            context: context,
            message: 'Something went wrong!',
            icon: Icons.error_outline,
            color: kError,
          );
        }
      },
      child: SizedBox(
        child: Column(
          children: [
            const VerificationDescriptionText(),
            OtpForm(controllers: otpController),
            ResendCodeText(
              onResend: () {
                showPopUpAlert(
                  context: context,
                  message: 'Using test number - no SMS sent',
                  icon: Icons.warning,
                  color: kWarning,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.079),
              child: CustomSqircleButton(
                text: 'Verify',
                onPressed: () {
                  final smsCode =
                      otpController.map((controller) => controller.text).join();

                  if (smsCode.isEmpty) {
                    showPopUpAlert(
                      context: context,
                      message: 'Please enter verification code',
                      icon: Icons.error_outline,
                      color: kError,
                    );
                    return;
                  }

                  if (smsCode.length < 6) {
                    showPopUpAlert(
                      context: context,
                      message: 'Please enter all 6 digits',
                      icon: Icons.error_outline,
                      color: kError,
                    );
                    return;
                  }

                  phoneAuthCubit.verifySmsCode(smsCode);
                },
                btnColor: kTextDarkerColor,
                textColor: kTextLightColor,
                isLoading: phoneAuthCubit.state is PhoneAuthLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
