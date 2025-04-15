import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_phone_text_field.dart';
import 'package:app/features/auth/presentation/views/widgets/join_view_description.dart';
import 'package:app/features/auth/presentation/views/widgets/join_view_title.dart';
import 'package:app/features/auth/presentation/views/widgets/phone_text_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class JoinViewBody extends StatelessWidget {
  const JoinViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;
    return Padding(
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
              const CustomPhoneTextField(),
              SizedBox(height: h * 0.075),
              CustomSqircleButton(
                text: 'Get code by SMS',
                onPressed: () {
                  GoRouter.of(context).push(AppRouter.kVervificationView);
                },
                btnColor: kTextDarkerColor,
                textColor: kTextLightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
