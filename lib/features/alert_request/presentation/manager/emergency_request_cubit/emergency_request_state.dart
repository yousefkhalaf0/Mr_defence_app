part of 'emergency_request_cubit.dart';

class EmergencyRequestState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final String? locationName;
  final String? locationCoordinates;
  final Position? position;
  final String? reportId;
  final bool isForMe;
  final double uploadProgress; // 0.0 to 1.0
  final String progressMessage;

  const EmergencyRequestState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.locationName,
    this.locationCoordinates,
    this.position,
    this.reportId,
    this.isForMe = true,
    this.uploadProgress = 0.0,
    this.progressMessage = '',
  });

  EmergencyRequestState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? locationName,
    String? locationCoordinates,
    Position? position,
    String? reportId,
    bool? isForMe,
    double? uploadProgress,
    String? progressMessage,
  }) {
    return EmergencyRequestState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      locationName: locationName ?? this.locationName,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      position: position ?? this.position,
      reportId: reportId ?? this.reportId,
      isForMe: isForMe ?? this.isForMe,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      progressMessage: progressMessage ?? this.progressMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    isSuccess,
    errorMessage,
    locationName,
    locationCoordinates,
    position,
    reportId,
    isForMe,
    uploadProgress,
    progressMessage,
  ];
}
