import 'dart:developer';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/widgets/show_pop_up_alert.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/manager/auto_capture_cubit/auto_capture_cubit.dart';

class AutoCapturePage extends StatelessWidget {
  final CameraLensDirection cameraDirection;
  final EmergencyType emergencyType;
  final String? frontPhotoPath;
  final String? requestType;

  const AutoCapturePage({
    super.key,
    required this.cameraDirection,
    required this.emergencyType,
    this.frontPhotoPath,
    required this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              AutoCaptureCubit(cameraDirection: cameraDirection)..loadCameras(),
      child: BlocConsumer<AutoCaptureCubit, AutoCaptureState>(
        listener: (context, state) {
          // Navigate when photo is captured
          if (state.capturedImagePath != null && state.isNavigating) {
            _handleNavigation(context, state.capturedImagePath!);
          }

          if (state.hasError) {
            log('Error at line 44 auto_capture_page: ${state.errorMessage}');
            showPopUpAlert(
              context: context,
              message: 'Something went wrong. Please try again.',
              icon: Icons.error_outline,
              color: kError,
            );
          }
        },
        builder: (context, state) {
          if (state.hasError) {
            return _buildErrorScreen(context, state.errorMessage);
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body:
                state.isControllerInitialized
                    ? _buildCameraView(context, state)
                    : _buildLoadingView(),
          );
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, String currentPath) {
    if (cameraDirection == CameraLensDirection.front) {
      context.pushReplacement(
        '/auto-capture',
        extra: {
          'direction': CameraLensDirection.back,
          'emergencyType': emergencyType,
          'frontPhotoPath': currentPath,
          'requestType': requestType,
        },
      );
    } else {
      context.pushReplacement(
        '/auto-record',
        extra: {
          'emergencyType': emergencyType,
          'frontPhotoPath': frontPhotoPath!,
          'backPhotoPath': currentPath,
          'requestType': requestType,
        },
      );
    }
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Initializing camera...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String errorMessage) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, AutoCaptureState state) {
    final cubit = context.read<AutoCaptureCubit>();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        (cubit.cameraController != null &&
                !state.isNavigating &&
                state.isControllerInitialized)
            ? CameraPreview(cubit.cameraController!)
            : Container(color: Colors.black),

        // UI Overlay
        SafeArea(
          child: Column(
            children: [
              // Header Text
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Helper.getResponsiveHeight(context, height: 16),
                ),
                child: Text(
                  cameraDirection == CameraLensDirection.front
                      ? 'Front footage'
                      : 'Back footage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Helper.getResponsiveWidth(context, width: 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Countdown Circle in the center
              if (state.countdown > 0 && !state.isCapturing)
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${state.countdown}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Bottom message
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32.0,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(69, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isCapturing)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          state.isCapturing
                              ? 'Processing...'
                              : 'Photo will be captured in ${state.countdown} seconds. Please stay on this page to avoid cancellation',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
