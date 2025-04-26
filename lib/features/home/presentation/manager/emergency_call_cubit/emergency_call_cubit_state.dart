import 'package:equatable/equatable.dart';

// Status enum for better state management
enum EmergencyCallStatus {
  initial,
  loading,
  created,
  accepted,
  expired,
  cancelled,
  error,
}

// Emergency contact model
class EmergencyContact {
  final String id;
  final String name;
  final String image;

  EmergencyContact({String? id, required this.name, required this.image})
    : id = id ?? name.toLowerCase().replaceAll(' ', '_');
}

// State class
class EmergencyCallState extends Equatable {
  final EmergencyCallStatus status;
  final int secondsElapsed;
  final int secondsRemaining;
  final String? errorMessage;
  final dynamic createdRequest; // Use correct type if available
  final String? acceptedByGuardian;
  final bool isExpired;
  final List<EmergencyContact> emergencyContacts;
  final bool isHandled;

  const EmergencyCallState({
    this.status = EmergencyCallStatus.initial,
    this.secondsElapsed = 0,
    this.secondsRemaining = 0,
    this.errorMessage,
    this.createdRequest,
    this.acceptedByGuardian,
    this.isExpired = false,
    this.isHandled = false,
    this.emergencyContacts = const [],
  });

  EmergencyCallState copyWith({
    EmergencyCallStatus? status,
    int? secondsElapsed,
    int? secondsRemaining,
    String? errorMessage,
    dynamic createdRequest, // Use correct type if available
    String? acceptedByGuardian,
    bool? isExpired,
    bool? isHandled,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return EmergencyCallState(
      status: status ?? this.status,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
      createdRequest: createdRequest ?? this.createdRequest,
      acceptedByGuardian: acceptedByGuardian ?? this.acceptedByGuardian,
      isExpired: isExpired ?? this.isExpired,
      isHandled: isHandled ?? this.isHandled,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    secondsElapsed,
    secondsRemaining,
    errorMessage,
    createdRequest,
    acceptedByGuardian,
    isExpired,
    isHandled,
    emergencyContacts,
  ];
}
