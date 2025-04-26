// auto_capture_cubit.dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/home/services/device_camera_service.dart';
import 'package:equatable/equatable.dart';

part 'auto_capture_state.dart';

class AutoCaptureCubit extends Cubit<AutoCaptureState> {
  CameraService? _cameraService;
  DeviceCameraService? _deviceCameraService;
  List<CameraDescription>? _cameras;
  final CameraLensDirection cameraDirection;
  bool _isNavigating = false;

  AutoCaptureCubit({required this.cameraDirection})
    : super(
        const AutoCaptureState(
          countdown: 3,
          isControllerInitialized: false,
          isCapturing: false,
          hasError: false,
          errorMessage: '',
          isNavigating: false,
        ),
      );

  void setNavigating(bool value) {
    _isNavigating = value;
    emit(state.copyWith(isNavigating: value));
  }

  Future<void> loadCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setError('No cameras available on this device');
        return;
      }
      await initializeCamera();
    } catch (e) {
      setError('Failed to load cameras: $e');
    }
  }

  void setError(String message) {
    emit(state.copyWith(hasError: true, errorMessage: message));
  }

  Future<void> disposeController() async {
    if (_cameraService != null) {
      await _cameraService!.dispose();
      _deviceCameraService = null;
      _cameraService = null;
      emit(state.copyWith(isControllerInitialized: false));
    }
  }

  Future<void> initializeCamera() async {
    if (_isNavigating) return;

    try {
      // Dispose old controller if exists
      await disposeController();

      if (_cameras == null || _cameras!.isEmpty) {
        await loadCameras();
        return;
      }

      // Find the requested camera
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == cameraDirection,
        orElse: () => _cameras!.first,
      );

      // Create a new controller using the service
      _deviceCameraService = DeviceCameraService(camera);
      _cameraService = _deviceCameraService;
      await _cameraService!.initialize();

      if (!_isNavigating) {
        emit(state.copyWith(isControllerInitialized: true));
        // Start the countdown after camera is initialized
        startCountdown();
      }
    } catch (e) {
      setError('Camera initialization error: $e');
    }
  }

  void startCountdown() {
    if (_isNavigating) return;
    emit(state.copyWith(countdown: 3));
    runCountdown();
  }

  void runCountdown() {
    if (_isNavigating) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (!_isNavigating) {
        final newCountdown = state.countdown - 1;
        emit(state.copyWith(countdown: newCountdown));

        if (newCountdown > 0) {
          runCountdown();
        } else {
          capturePhoto();
        }
      }
    });
  }

  Future<void> capturePhoto() async {
    if (_cameraService == null ||
        !state.isControllerInitialized ||
        _isNavigating) {
      setError('Camera is not ready');
      return;
    }

    try {
      emit(state.copyWith(isCapturing: true));

      // Take the picture
      final XFile image = await _cameraService!.capturePhoto();
      debugPrint('Image captured at: ${image.path}');

      // First emit the captured path
      emit(state.copyWith(capturedImagePath: image.path, isCapturing: false));

      // Then set navigating flag to prevent further operations
      setNavigating(true);

      // Only dispose after the state has been updated
      await disposeController();
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      emit(
        state.copyWith(
          isCapturing: false,
          isNavigating: false,
          hasError: true,
          errorMessage: 'Error capturing photo: $e',
        ),
      );
    }
  }

  CameraController? get cameraController => _deviceCameraService?.controller;

  @override
  Future<void> close() {
    disposeController();
    return super.close();
  }
}
