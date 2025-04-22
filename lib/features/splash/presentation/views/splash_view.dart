import 'dart:async';
import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/enums.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/splash/presentation/views/widgets/splash_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    splashNavigating();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SplashViewBody());
  }

  void splashNavigating() {
    Timer(const Duration(seconds: 3), () {
      final isOnBoarded = MyShared.getBoolean(key: MySharedKeys.onBoarding);
      final isJoined =
          MyShared.getString(key: MySharedKeys.userPhoneNumber).isNotEmpty;
      final isSetup = MyShared.getBoolean(key: MySharedKeys.setUp);

      if (!isOnBoarded) {
        GoRouter.of(context).go(AppRouter.kOnBoardingView);
      } else if (!isJoined) {
        GoRouter.of(context).go(AppRouter.kJoinView);
      } else if (!isSetup) {
        GoRouter.of(context).go(AppRouter.kSetUpView);
      } else {
        GoRouter.of(context).go(AppRouter.kHomeView);
      }
    });
  }
}
