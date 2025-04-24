// request_state.dart

part of 'sos_request_cubit.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestCheckingPermissions extends RequestState {}

class RequestPermissionsGranted extends RequestState {}

class RequestPermissionDenied extends RequestState {
  final String message;

  const RequestPermissionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestLocationLoading extends RequestState {}

class RequestLocationReady extends RequestState {
  final Position position;
  final String locationName;

  const RequestLocationReady({
    required this.position,
    required this.locationName,
  });

  @override
  List<Object?> get props => [position, locationName];
}

class RequestLocationError extends RequestState {
  final String message;

  const RequestLocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestEmergencyTypeSelected extends RequestState {
  final EmergencyType emergencyType;

  const RequestEmergencyTypeSelected(this.emergencyType);

  @override
  List<Object?> get props => [emergencyType];
}

class RequestReadyForCapture extends RequestState {}

class RequestCapturingFront extends RequestState {}

class RequestFrontCaptured extends RequestState {
  final String frontPhotoPath;

  const RequestFrontCaptured(this.frontPhotoPath);

  @override
  List<Object?> get props => [frontPhotoPath];
}

class RequestCapturingBack extends RequestState {
  final String frontPhotoPath;

  const RequestCapturingBack(this.frontPhotoPath);

  @override
  List<Object?> get props => [frontPhotoPath];
}

class RequestBackCaptured extends RequestState {
  final String frontPhotoPath;
  final String backPhotoPath;

  const RequestBackCaptured(this.frontPhotoPath, this.backPhotoPath);

  @override
  List<Object?> get props => [frontPhotoPath, backPhotoPath];
}

class RequestRecordingAudio extends RequestState {
  final String frontPhotoPath;
  final String backPhotoPath;

  const RequestRecordingAudio(this.frontPhotoPath, this.backPhotoPath);

  @override
  List<Object?> get props => [frontPhotoPath, backPhotoPath];
}

class RequestAudioRecorded extends RequestState {
  final String frontPhotoPath;
  final String backPhotoPath;
  final String? audioPath;

  const RequestAudioRecorded(
    this.frontPhotoPath,
    this.backPhotoPath,
    this.audioPath,
  );

  @override
  List<Object?> get props => [frontPhotoPath, backPhotoPath, audioPath];
}

class RequestProcessing extends RequestState {}

class RequestSuccess extends RequestState {
  final String requestId;
  final EmergencyType emergencyType;
  final Position position;
  final String locationName;
  final String? frontPhotoPath;
  final String? backPhotoPath;
  final String? audioPath;

  const RequestSuccess({
    required this.requestId,
    required this.emergencyType,
    required this.position,
    required this.locationName,
    this.frontPhotoPath,
    this.backPhotoPath,
    this.audioPath,
  });

  @override
  List<Object?> get props => [
    requestId,
    emergencyType,
    position,
    locationName,
    frontPhotoPath,
    backPhotoPath,
    audioPath,
  ];
}

class RequestError extends RequestState {
  final String message;

  const RequestError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestExpired extends RequestState {}

class RequestCreated extends RequestState {
  final SOSRequest request;

  const RequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestAccepted extends RequestState {
  final String guardianId;
  final SOSRequest request;

  const RequestAccepted({required this.guardianId, required this.request});

  @override
  List<Object?> get props => [guardianId, request];
}

class RequestLoading extends RequestState {}
