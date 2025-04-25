import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingAppBar extends StatelessWidget {
  const OnBoardingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () {
          BlocProvider.of<OnBoardingCubit>(
            context,
          ).finishOnBoarding(context, true, AppRouter.kJoinView);
        },
        child: Text(
          'Skip',
          style: TextStyle(
            color: kNeutral50,
            fontSize: Helper.getResponsiveFontSize(context, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
