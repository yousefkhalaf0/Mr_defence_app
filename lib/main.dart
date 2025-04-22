import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/firebase_service.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/auth/presentation/manager/phone_auth/phone_auth_cubit.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:app/firebase_options.dart';
// import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyShared.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    //device preview
    //   DevicePreview(enabled: true, builder: (context) => const MrDefence()),
    // );
    const MrDefence(),
  );
}

class MrDefence extends StatelessWidget {
  const MrDefence({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnBoardingCubit>(create: (context) => OnBoardingCubit()),
        BlocProvider<EmergencyCubit>(create: (context) => EmergencyCubit()),
        BlocProvider<PhoneAuthCubit>(
          create: (context) => PhoneAuthCubit(FirebaseService()),
        ),
      ],
      child: MaterialApp.router(
        //device preview
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackGroundColor,
          textTheme: GoogleFonts.interTextTheme(),
        ),
      ),
    );
  }
}
