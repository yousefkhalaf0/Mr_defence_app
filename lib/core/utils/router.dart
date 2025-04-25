import 'package:app/features/auth/presentation/manager/profile_image_cubit/profile_image_cubit.dart';
import 'package:app/features/auth/presentation/manager/user_data_cubit/user_data_cubit.dart';
import 'package:app/features/auth/presentation/views/join_view.dart';
import 'package:app/features/auth/presentation/views/setup_view.dart';
import 'package:app/features/auth/presentation/views/verification_view.dart';
import 'package:app/features/home/presentation/views/alert_view.dart';
import 'package:app/features/auth/presentation/views/vervification_view.dart';

import 'package:app/features/home/presentation/views/home_page.dart';
import 'package:app/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kSplashView = '/';
  static const kOnBoardingView = '/onBoardingView';
  static const kJoinView = '/joinView';
  static const kVervificationView = '/verificationView';
  static const kSetUpView = '/setUpView';
  static const kHomeView = '/homeView';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: kSplashView,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kOnBoardingView,
        builder: (context, state) => const OnBoardingView(),
      ),
      GoRoute(path: kJoinView, builder: (context, state) => const JoinView()),

      GoRoute(
        path: kVervificationView,
        builder: (context, state) => const VerificationView(),
      ),
      GoRoute(
        path: kSetUpView,
        builder: (context, state) {
          final isFromProfile =
              state.extra != null &&
              (state.extra as Map)['isFromProfile'] == true;

          return MultiBlocProvider(
            providers: [BlocProvider(create: (context) => UserDataCubit())],
            child: SetUpView(isFromProfile: isFromProfile),
          );
        },
      ),
      GoRoute(path: kHomeView, builder: (context, state) => const HomePage()),
    ],
  );
}
