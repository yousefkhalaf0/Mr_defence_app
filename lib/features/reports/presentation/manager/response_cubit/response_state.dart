part of 'response_cubit.dart';

abstract class EmergencyRequestState extends Equatable {
  const EmergencyRequestState();

  @override
  List<Object> get props => [];
}

class EmergencyRequestInitial extends EmergencyRequestState {}

class EmergencyRequestLoading extends EmergencyRequestState {}

class EmergencyRequestProcessing extends EmergencyRequestState {}

class EmergencyRequestUserLoaded extends EmergencyRequestState {
  final Map<String, dynamic> userData;

  const EmergencyRequestUserLoaded(this.userData);

  @override
  List<Object> get props => [userData];
}

class EmergencyRequestSuccess extends EmergencyRequestState {
  final String message;

  const EmergencyRequestSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EmergencyRequestFailed extends EmergencyRequestState {
  final String message;

  const EmergencyRequestFailed(this.message);

  @override
  List<Object> get props => [message];
}

class EmergencyRespondersLoaded extends EmergencyRequestState {
  final List<Map<String, dynamic>> responders;

  const EmergencyRespondersLoaded(this.responders);

  @override
  List<Object> get props => [responders];
}

class EmergencyMediaUpdated extends EmergencyRequestState {
  final List<String> images;
  final List<String> videos;

  const EmergencyMediaUpdated(this.images, this.videos);

  @override
  List<Object> get props => [images, videos];
}

class EmergencyLocationUpdated extends EmergencyRequestState {
  final GeoPoint location;
  final String locationName;

  const EmergencyLocationUpdated(this.location, this.locationName);

  @override
  List<Object> get props => [location, locationName];
}
