import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await MyShared.init();
  runApp(const MrDefence());
}

class MrDefence extends StatelessWidget {
  const MrDefence({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnBoardingCubit>(create: (context) => OnBoardingCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          scaffoldBackgroundColor: kPrimaryColor,
          textTheme: GoogleFonts.interTextTheme(),
        ),
      ),
    );
  }
}
