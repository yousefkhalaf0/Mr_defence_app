import 'package:app/core/widgets/welcome_views_back_ground.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_Builder.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_app_bar.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_navigation_button.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingViewBody extends StatelessWidget {
  const OnBoardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeViewsBackGround(
      content: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
          builder: (context, state) {
            return Column(
              children: [
                const OnBoardingAppBar(),
                const OnBoardingBuilder(),
                const OnBoardingPageIndicator(),
                onBoardingNavigateButton(context),
              ],
            );
          },
        ),
      ),
    );
  }
}
