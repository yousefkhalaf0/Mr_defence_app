import 'package:app/features/on_boarding/data/models/on_boarding_model.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:app/features/on_boarding/presentation/views/widgets/on_boarding_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingBuilder extends StatelessWidget {
  const OnBoardingBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller:
            BlocProvider.of<OnBoardingCubit>(context).onBoardingController,
        physics: const BouncingScrollPhysics(),
        itemCount: OnBoardingModel.data.length,
        itemBuilder:
            (context, inedex) => OnBoardingContent(
              onBoardingModel: OnBoardingModel.data[inedex],
            ),
        onPageChanged: (index) {
          BlocProvider.of<OnBoardingCubit>(context).changePageView(index);
        },
      ),
    );
  }
}
