import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kOnBoardingView = '/onBoardingView';
  static const kHomeView = '/homeView';

  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashView()),
      // GoRoute(path: kOnBoardingView, builder: (context, state) => OnBoardingView()),
      // GoRoute(path: kHomeView, builder: (context, state) => HomeView()),
    ],
  );
}
