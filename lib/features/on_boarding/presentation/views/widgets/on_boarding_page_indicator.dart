import 'package:app/core/utils/constants.dart';
import 'package:app/features/on_boarding/data/models/on_boarding_model.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingPageIndicator extends StatelessWidget {
  const OnBoardingPageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: SmoothPageIndicator(
        controller:
            BlocProvider.of<OnBoardingCubit>(context).onBoardingController,
        count: OnBoardingModel.data.length,
        effect: const SlideEffect(
          type: SlideType.slideUnder,
          spacing: 4,
          radius: 30,
          dotWidth: 13,
          dotHeight: 13,
          dotColor: kPageIndicatorDotLightColor,
          activeDotColor: kTextRedColor,
        ),
      ),
    );
  }
}
