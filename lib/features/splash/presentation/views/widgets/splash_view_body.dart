import 'package:app/core/widgets/welcome_views_back_ground.dart';
import 'package:app/features/splash/presentation/views/widgets/app_name_text.dart';
import 'package:app/features/splash/presentation/views/widgets/app_logo_widget.dart';
import 'package:flutter/material.dart';

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeViewsBackGround(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [AppLogo(), AppNameText()],
      ),
    );
  }
}
