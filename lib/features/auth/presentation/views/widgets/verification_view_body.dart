import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/manager/phone_auth/phone_auth_cubit.dart';
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
          // Navigate to home screen
          GoRouter.of(context).go(AppRouter.kHomeView);
        } else if (state is PhoneAuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: SizedBox(
        child: Column(
          children: [
            const VerificationDescriptionText(),
            OtpForm(controllers: otpController),
            ResendCodeText(
              onResend: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Using test number - no SMS sent'),
                  ),
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
                  phoneAuthCubit.verifySmsCode(smsCode);
                },
                btnColor: kTextDarkerColor,
                textColor: kTextLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
