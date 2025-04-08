import 'package:app/core/utils/constants.dart';
import 'package:app/features/splash/presentation/views/widgets/app_name_text.dart';
import 'package:app/features/splash/presentation/views/widgets/app_logo_widget.dart';
import 'package:flutter/material.dart';

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kGradientColor1, kGradientColor2],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [AppLogo(), AppNameText()],
      ),
    );
  }
}
