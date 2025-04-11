import 'package:app/core/widgets/welcome_views_back_ground.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_Builder.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_app_bar.dart';
import 'package:flutter/material.dart';

class OnBoardingViewBody extends StatelessWidget {
  const OnBoardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeViewsBackGround(
      content: Column(
        children: [
          const SizedBox(height: 16),
          OnBoardingAppBar(),
          OnBoardingBuilder(),
        ],
      ),
    );
  }
}
