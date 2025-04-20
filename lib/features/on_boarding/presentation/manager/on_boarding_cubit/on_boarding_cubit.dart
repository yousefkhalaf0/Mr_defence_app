import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/enums.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
part 'on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit() : super(OnBoardingInitial());

  final onBoardingController = PageController();
  int currentPage = 0;

  void changePageView(int index) {
    onBoardingController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    currentPage = index;
    emit(ChangePageViewState());
  }

  void finishOnBoarding(context, bool isLast, String viewPath) {
    MyShared.setBoolean(key: MySharedKeys.onBoarding, value: isLast);
    GoRouter.of(context).pushReplacement(viewPath);
    emit(FinishOnBoardingState());
  }

  @override
  Future<void> close() {
    onBoardingController.dispose();
    return super.close();
  }
}
