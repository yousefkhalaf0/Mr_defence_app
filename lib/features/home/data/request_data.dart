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

enum RequestType {
  alert,
  sosRequest;

  String get displayName {
    switch (this) {
      case RequestType.alert:
        return "ALERT";
      case RequestType.sosRequest:
        return "SOS";
    }
  }
}

abstract class EmergencyRequest {
  String? id;
  String? userId;

  DateTime? timestamp;
  late GeoPoint location;
  late String locationName;
  late EmergencyType type;
  late RequestStatus status;
  late List<String> guardianIds;
  EmergencyRequest({
    required this.id,
    required this.userId,
    required this.location,
    required this.locationName,
    required this.status,
    required this.guardianIds,
    required this.type,
  });
}

class AlertRequest extends EmergencyRequest {
  final String description;
  final List<String> pictureUrls;
  final List<String> videoUrls;
  final List<String> voiceRecordUrls;

  AlertRequest({
    required super.id,
    required super.userId,
    required super.location,
    required super.locationName,
    required super.status,
    required super.guardianIds,
    required super.type,
    required this.description,
    required this.pictureUrls,
    required this.videoUrls,
    required this.voiceRecordUrls,
  });

  factory AlertRequest.fromFirestore(
    DocumentSnapshot doc,
    EmergencyType emergencyType,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return AlertRequest(
      id: doc.id,
      userId: data['user_id'] ?? '',
      location: data['occured_location'] as GeoPoint? ?? const GeoPoint(0, 0),
      locationName: data['location_name'] ?? 'Unknown location',
      type: emergencyType,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => RequestStatus.pending,
      ),
      guardianIds: List<String>.from(data['reciever_gaurdians'] ?? []),
      description: data['description'] ?? '',
      pictureUrls: List<String>.from(data['pictures'] ?? []),
      videoUrls: List<String>.from(data['videos'] ?? []),
      voiceRecordUrls: List<String>.from(data['voice_records'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'occured_location': location,
      'location_name': locationName,
      'emergecy_type': type.name,
      'status': status.name,
      'reciever_gaurdians': guardianIds,
      'description': description,
      'pictures': pictureUrls,
      'videos': videoUrls,
      'voice_records': voiceRecordUrls,
      'who_happened': true,
      'request_type': "ALERT",
      'occured_time': FieldValue.serverTimestamp(),
    };
  }
}

class SOSRequest extends EmergencyRequest {
  String frontCameraPhotoUrl;
  String backCameraPhotoUrl;
  String audioRecordingUrl;
  Duration recordingDuration;

  SOSRequest({
    required super.id,
    required super.userId,
    required super.location,
    required super.locationName,
    required super.type,
    required super.status,
    required super.guardianIds,
    required this.frontCameraPhotoUrl,
    required this.backCameraPhotoUrl,
    required this.audioRecordingUrl,
    required this.recordingDuration,
  });

  factory SOSRequest.fromFirestore(
    DocumentSnapshot doc,
    EmergencyType emergencyType,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract media URLs from arrays
    final List<dynamic> pictures = data['pictures'] ?? [];
    final List<dynamic> voiceRecords = data['voice_records'] ?? [];

    return SOSRequest(
      id: doc.id,
      userId: data['user_id'] ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      locationName: data['location_name'] ?? 'Unknown location',
      type: emergencyType,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => RequestStatus.pending,
      ),
      guardianIds: List<String>.from(data['guardian_ids'] ?? []),
      frontCameraPhotoUrl: pictures.isNotEmpty ? pictures[0] : '',
      backCameraPhotoUrl: pictures.length > 1 ? pictures[1] : '',
      audioRecordingUrl: voiceRecords.isNotEmpty ? voiceRecords[0] : '',
      recordingDuration: Duration(
        seconds:
            (data['recording_duration'] ?? 0) is int
                ? data['recording_duration'] ?? 0
                : 0,
      ),
    );
  }
}
