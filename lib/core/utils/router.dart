import 'package:app/features/auth/presentation/views/join_view.dart';
import 'package:app/features/auth/presentation/views/vervification_view.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/home/presentation/views/auto_capture_page.dart';
import 'package:app/features/home/presentation/views/auto_record_page.dart';
import 'package:app/features/home/presentation/views/test_emergency_call_page.dart';
import 'package:app/features/home/presentation/views/home_page.dart';
import 'package:app/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kSplashView = '/';
  static const kOnBoardingView = '/onBoardingView';
  static const kJoinView = '/joinView';
  static const kVervificationView = '/verificationView';
  static const kHomeView = '/homeView';
  static const kAutoCapture = '/auto-capture';
  static const kAutoRecord = '/auto-record';
  static const kEmergencyCalling = '/emergency-calling';

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
      GoRoute(path: kHomeView, builder: (context, state) => const HomePage()),
      GoRoute(
        path: kAutoCapture,
        builder: (context, state) {
          // Handle both cases - with and without extra parameters
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};

          // Debug log to see what's being passed
          debugPrint('AutoCapture Route - Extra parameters: $extra');

          // Extract parameters with proper null safety
          final cameraDirection =
              extra['direction'] as CameraLensDirection? ??
              CameraLensDirection.front;

          // For the emergency type, we need special handling as it's required
          final emergencyType = extra['emergencyType'];
          if (emergencyType == null) {
            debugPrint('ERROR: emergencyType is missing');
            // Return error widget or redirect
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 20),
                    Text('Missing emergency type information'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final frontPhotoPath = extra['frontPhotoPath'] as String?;

          // Create the page with proper parameters
          return AutoCapturePage(
            cameraDirection: cameraDirection,
            emergencyType: emergencyType as EmergencyType,
            frontPhotoPath: frontPhotoPath,
          );
        },
      ),
      GoRoute(
        path: kAutoRecord,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};

          // Debug log
          debugPrint('AutoRecord Route - Extra parameters: $extra');

          // Extract parameters with proper validation
          final emergencyType = extra['emergencyType'];
          final frontPhotoPath = extra['frontPhotoPath'] as String?;
          final backPhotoPath = extra['backPhotoPath'] as String?;

          if (emergencyType == null ||
              frontPhotoPath == null ||
              backPhotoPath == null) {
            debugPrint('ERROR: Missing required parameters for AutoRecordPage');
            // Return error widget or redirect
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 20),
                    Text('Missing required parameters'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return AutoRecordPage(
            emergencyType: emergencyType as EmergencyType,
            frontPhotoPath: frontPhotoPath,
            backPhotoPath: backPhotoPath,
          );
        },
      ),
      GoRoute(
        path: kEmergencyCalling,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};

          // Debug log
          debugPrint('EmergencyCalling Route - Extra parameters: $extra');

          final emergencyType = extra['emergencyType'];
          final frontPhotoPath = extra['frontPhotoPath'] as String?;
          final backPhotoPath = extra['backPhotoPath'] as String?;
          final audioPath = extra['audioPath'] as String?;

          if (emergencyType == null ||
              frontPhotoPath == null ||
              backPhotoPath == null) {
            debugPrint(
              'ERROR: Missing required parameters for EmergencyCallingPage',
            );
            // Return error widget or redirect
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 20),
                    Text('Missing required parameters'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return EmergencyCallingPage(
            emergencyType: emergencyType as EmergencyType,
            frontPhotoPath: frontPhotoPath,
            backPhotoPath: backPhotoPath,
            audioPath: audioPath ?? '',
          );
        },
      ),
    ],
  );
}
