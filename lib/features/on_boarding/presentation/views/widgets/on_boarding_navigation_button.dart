import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/on_boarding/data/models/on_boarding_model.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:app/core/widgets/custon_sqircle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

CustomSqircleButton onBoardingNavigateButton(BuildContext context) {
  int currentPage = BlocProvider.of<OnBoardingCubit>(context).currentPage;
  PageController onBoardingController =
      BlocProvider.of<OnBoardingCubit>(context).onBoardingController;

  return currentPage == 0
      ? CustomSqircleButton(
        text: 'Get Started',
        btnColor: kTextLightColor,
        textColor: kTextDarkerColor,
        onPressed:
            () => onBoardingController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            ),
      )
      : currentPage != OnBoardingModel.data.length - 1
      ? CustomSqircleButton(
        text: 'Next',
        btnColor: kTextLightColor,
        textColor: kTextDarkerColor,
        onPressed:
            () => onBoardingController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            ),
      )
      : CustomSqircleButton(
        text: 'Join us',
        btnColor: kTextLightColor,
        textColor: kTextDarkerColor,
        onPressed: () {
          BlocProvider.of<OnBoardingCubit>(
            context,
          ).finishOnBoarding(context, true, AppRouter.kJoinView);
        },
      );
}
