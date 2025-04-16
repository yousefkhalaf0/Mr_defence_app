import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/manager/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:app/features/auth/presentation/views/widgets/otp_form.dart';
import 'package:app/features/auth/presentation/views/widgets/resend_code_text.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_description_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerificationViewBody extends StatelessWidget {
  VerificationViewBody({
    super.key,
    required this.phone,
    required this.verificationId,
  });
  final String phone;
  final String verificationId;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listener: (context, state) {
        if (state is PhoneAuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PhoneAuthSuccess) {
          context.go(AppRouter.kHomeView);
        }
      },
      child: SizedBox(
        child: Column(
          children: [
            const VerificationDescriptionText(),
            const OtpForm(),
            ResendCodeText(
              onResend: () => context.read<PhoneAuthCubit>().resendCode(phone),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.079),
              child: BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
                builder: (context, state) {
                  return CustomSqircleButton(
                    text: 'Verify',
                    onPressed: () {
                      final otp =
                          OtpFormKeys.formKey.currentState?.getOtp() ?? '';
                      if (otp.length == 4) {
                        context.read<PhoneAuthCubit>().verifyOtpCode(otp);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid OTP code'),
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
            ),
          ],
        ),
      ),
    );
  }
}
