import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/on_boarding/presentation/manager/on_boarding_cubit/on_boarding_cubit.dart';
import 'package:app/firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyShared.init();
  await Supabase.initialize(
    url: 'https://cljfswpvzoanukczqnnc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNsamZzd3B2em9hbnVrY3pxbm5jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ4ODE2ODAsImV4cCI6MjA2MDQ1NzY4MH0.hMLa1tlCJ4w-QSGpK10nrBmWbbN6GchA59g-JH_9W_Y',
  );
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    //   //device preview
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
      ],
      child: MaterialApp.router(
        // //device preview
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
