part of 'sos_request_cubit.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestCapturingPhoto extends RequestState {
  final CameraLensDirection direction;

  const RequestCapturingPhoto(this.direction);

  @override
  List<Object?> get props => [direction];
}

class RequestRecordingAudio extends RequestState {
  final Duration duration;

  const RequestRecordingAudio(this.duration);

  @override
  List<Object?> get props => [duration];
}

class RequestCreated extends RequestState {
  final SOSRequest request;

  const RequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestAccepted extends RequestState {
  final String guardianId;

  const RequestAccepted(this.guardianId);

  @override
  List<Object?> get props => [guardianId];
}

class RequestExpired extends RequestState {}

class RequestError extends RequestState {
  final String message;

  const RequestError(this.message);

  @override
  List<Object?> get props => [message];
}
