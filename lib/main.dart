import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MrDefence());
}

class MrDefence extends StatelessWidget {
  const MrDefence({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        scaffoldBackgroundColor: kPrimaryColor,
        textTheme: GoogleFonts.interTextTheme(),
      ),
    );
  }
}
