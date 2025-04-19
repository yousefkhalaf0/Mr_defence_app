import 'package:app/features/auth/presentation/views/join_view.dart';
import 'package:app/features/auth/presentation/views/vervification_view.dart';

import 'package:app/features/home/presentation/views/home_page.dart';
import 'package:app/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:app/features/profile/presentation/views/profile_page.dart';
import 'package:app/features/profile/presentation/views/setting_page.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kSplashView = '/';
  static const kOnBoardingView = '/onBoardingView';
  static const kJoinView = '/joinView';
  static const kVervificationView = '/verificationView';
  static const kHomeView = '/homeView';
  static const kProfilePage = '/profilePage';
  static const kSetting = '/setting';

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
        builder: (context, state) => const VervificationView(),
      ),
      GoRoute(path: kHomeView, builder: (context, state) => const AlertView()),
      GoRoute(
        path: kProfilePage,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: kSetting,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: kHomeView, builder: (context, state) => const HomePage()),
    ],
  );
}
