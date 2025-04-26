// auto_capture_state.dart
part of 'auto_capture_cubit.dart';

class AutoCaptureState extends Equatable {
  final int countdown;
  final bool isControllerInitialized;
  final bool isCapturing;
  final bool hasError;
  final String errorMessage;
  final bool isNavigating;
  final String? capturedImagePath;

  const AutoCaptureState({
    required this.countdown,
    required this.isControllerInitialized,
    required this.isCapturing,
    required this.hasError,
    required this.errorMessage,
    required this.isNavigating,
    this.capturedImagePath,
  });

  AutoCaptureState copyWith({
    int? countdown,
    bool? isControllerInitialized,
    bool? isCapturing,
    bool? hasError,
    String? errorMessage,
    bool? isNavigating,
    String? capturedImagePath,
  }) {
    return AutoCaptureState(
      countdown: countdown ?? this.countdown,
      isControllerInitialized:
          isControllerInitialized ?? this.isControllerInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isNavigating: isNavigating ?? this.isNavigating,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    );
  }

  @override
  List<Object?> get props => [
    countdown,
    isControllerInitialized,
    isCapturing,
    hasError,
    errorMessage,
    isNavigating,
    capturedImagePath,
  ];
}
