// ignore_for_file: unused_import
import 'package:app/features/auth/presentation/views/join_view.dart';
import 'package:app/features/home/presentation/views/alert_view.dart';
import 'package:app/features/home/presentation/views/home_page.dart';
import 'package:app/features/auth/presentation/views/setup_view.dart';
import 'package:app/features/auth/presentation/views/verification_view.dart';
import 'package:app/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:app/features/profile/presentation/views/add_contacts_page.dart';
import 'package:app/features/profile/presentation/views/profile_page.dart';
import 'package:app/features/profile/presentation/views/setting_page.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kSplashView = '/';
  static const kOnBoardingView = '/onBoardingView';
  static const kJoinView = '/joinView';
  static const kVervificationView = '/verificationView';
  static const kSetUpView = '/setUpView';
  static const kHomeView = '/homeView';
  static const kProfilePage = '/profilePage';
  static const kSetting = '/setting';
  static const kAddContact = '/addContactsPage';

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
        path: kProfilePage,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: kSetting,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: kHomeView, builder: (context, state) => const HomePage()),
      GoRoute(path: kSetUpView, builder: (context, state) => const SetUpView()),
      GoRoute(path: kHomeView, builder: (context, state) => const AlertView()),
      GoRoute(
        path: kAddContact,
        builder: (context, state) => const AddContactsPage(),
      ),
    ],
  );
}
