// Provides GeoPoint class
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending, // Request created but not yet sent
  active, // Sent to guardians, awaiting response
  accepted, // A guardian has accepted the request
  inProgress, // Help is on the way/being provided
  completed, // Emergency resolved successfully
  expired, // Timed out without response
  cancelled, // Manually cancelled by sender
}

abstract class EmergencyRequest {
  String? id;
  String? userId;
  String? userName;
  String? userPhone;
  DateTime? timestamp;
  late GeoPoint location;
  late String locationName; // e.g., "Kolkata, India"
  late EmergencyType type;
  late RequestStatus status;
  late List<String> guardianIds;
}

class RegularRequest extends EmergencyRequest {
  List<String>? videoUrls; // For live video uploads
  String? description;
}

class SOSRequest extends EmergencyRequest {
  String frontCameraPhotoUrl;
  String backCameraPhotoUrl;
  String audioRecordingUrl;
  Duration recordingDuration;

  SOSRequest({
    required this.frontCameraPhotoUrl,
    required this.backCameraPhotoUrl,
    required this.audioRecordingUrl,
    required this.recordingDuration,
  });
}
