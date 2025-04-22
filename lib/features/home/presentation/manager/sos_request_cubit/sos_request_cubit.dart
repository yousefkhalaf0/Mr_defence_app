import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:camera/camera.dart' show CameraLensDirection;
part 'sos_request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  List<CameraDescription> cameras = [];
  String? userId;
  String? userName;
  String? userPhone;

  RequestCubit() : super(RequestInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _requestPermissions();
      cameras = await availableCameras();
      await _recorder.openRecorder();
    } catch (e) {
      emit(RequestError('Failed to initialize: $e'));
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();
  }

  Future<void> startSosRequest(EmergencyType emergencyType) async {
    try {
      emit(RequestLoading());

      // Step 1: Get location
      final location = await _getCurrentLocation();
      if (location == null) {
        emit(RequestError('Unable to get location'));
        return;
      }

      // Step 2: Take photos with front and back cameras
      final frontPhoto = await _takePhoto(CameraLensDirection.front);
      final backPhoto = await _takePhoto(CameraLensDirection.back);

      // Step 3: Record audio
      final audioPath = await _recordAudio(Duration(minutes: 2));

      // Step 4: Upload files and create SOS request
      final frontPhotoUrl = await _uploadFile(frontPhoto, 'front_photo');
      final backPhotoUrl = await _uploadFile(backPhoto, 'back_photo');
      final audioUrl = await _uploadFile(audioPath, 'audio');

      final sosRequest = SOSRequest(
        frontCameraPhotoUrl: frontPhotoUrl,
        backCameraPhotoUrl: backPhotoUrl,
        audioRecordingUrl: audioUrl,
        recordingDuration: Duration(minutes: 2),
      );

      // Set required fields on the EmergencyRequest base class
      sosRequest.userId = userId;
      sosRequest.userName = userName;
      sosRequest.userPhone = userPhone;
      sosRequest.timestamp = DateTime.now();
      sosRequest.location = GeoPoint(location.latitude, location.longitude);
      sosRequest.locationName = await _getLocationName(location);
      sosRequest.type = emergencyType;
      sosRequest.status = RequestStatus.active;
      sosRequest.guardianIds = await _getGuardianIds();

      // Save the request to Firestore
      final requestId = await _saveRequestToFirestore(sosRequest);
      sosRequest.id = requestId;

      // Notify guardians
      await _notifyGuardians(sosRequest);

      emit(RequestCreated(sosRequest));

      // Start timeout timer
      _startRequestTimer(requestId);
    } catch (e) {
      emit(RequestError('Failed to create SOS request: $e'));
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }

  Future<String> _takePhoto(CameraLensDirection direction) async {
    emit(RequestCapturingPhoto(direction));

    final CameraDescription camera = cameras.firstWhere(
      (cam) => cam.lensDirection == direction,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await controller.initialize();

    // Wait 3 seconds before taking photo (as shown in your UI)
    await Future.delayed(Duration(seconds: 3));

    final XFile photo = await controller.takePicture();
    await controller.dispose();

    return photo.path;
  }

  Future<String> _recordAudio(Duration duration) async {
    emit(RequestRecordingAudio(duration));

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/emergency_audio.aac';

    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

    // Record for the specified duration
    await Future.delayed(duration);

    await _recorder.stopRecorder();

    return path;
  }

  Future<String> _uploadFile(String filePath, String fileType) async {
    final file = File(filePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('emergencies')
        .child(userId ?? 'unknown')
        .child(
          '$timestamp-$fileType${fileType.contains('photo') ? '.jpg' : '.aac'}',
        );

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<List<String>> _getGuardianIds() async {
    // In a real app, you would fetch this from your database
    // For now, returning a placeholder
    return ['guardian1', 'guardian2', 'guardian3'];
  }

  Future<String> _saveRequestToFirestore(SOSRequest request) async {
    final docRef = await FirebaseFirestore.instance
        .collection('emergency_requests')
        .add({
          'userId': request.userId,
          'userName': request.userName,
          'userPhone': request.userPhone,
          'timestamp': request.timestamp,
          'location': request.location,
          'locationName': request.locationName,
          'type': request.type.name,
          'status': request.status.toString().split('.').last,
          'guardianIds': request.guardianIds,
          'frontCameraPhotoUrl': request.frontCameraPhotoUrl,
          'backCameraPhotoUrl': request.backCameraPhotoUrl,
          'audioRecordingUrl': request.audioRecordingUrl,
          'recordingDuration': request.recordingDuration.inSeconds,
          'requestType': 'SOS',
        });

    return docRef.id;
  }

  Future<void> _notifyGuardians(SOSRequest request) async {
    // In a real app, you would send push notifications or other alerts
    // This would typically involve a cloud function or a backend service
    // For demonstration purposes, this is left as a placeholder
  }

  void _startRequestTimer(String requestId) {
    // Start a 5-minute timer as specified in your requirements
    Timer(Duration(minutes: 5), () {
      _closeRequest(requestId);
    });
  }

  Future<void> _closeRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(requestId)
          .update({'status': RequestStatus.expired.toString().split('.').last});

      emit(RequestExpired());
    } catch (e) {
      emit(RequestError('Failed to close request: $e'));
    }
  }

  Future<void> guardianAcceptRequest(
    String requestId,
    String guardianId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(requestId)
          .update({
            'status': RequestStatus.accepted.toString().split('.').last,
            'acceptedBy': guardianId,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      emit(RequestAccepted(guardianId));
    } catch (e) {
      emit(RequestError('Failed to accept request: $e'));
    }
  }

  @override
  Future<void> close() {
    _recorder.closeRecorder();
    return super.close();
  }

  Future<void> processSosRequest(
    EmergencyType emergencyType,
    String frontPhotoPath,
    String backPhotoPath,
    String audioPath,
  ) async {
    try {
      emit(RequestLoading());

      // Step 1: Get location
      final location = await _getCurrentLocation();
      if (location == null) {
        emit(RequestError('Unable to get location'));
        return;
      }

      // Step 2: Upload files
      final frontPhotoUrl = await _uploadFile(frontPhotoPath, 'front_photo');
      final backPhotoUrl = await _uploadFile(backPhotoPath, 'back_photo');
      final audioUrl = await _uploadFile(audioPath, 'audio');

      // Step 3: Create SOS request
      final sosRequest = SOSRequest(
        frontCameraPhotoUrl: frontPhotoUrl,
        backCameraPhotoUrl: backPhotoUrl,
        audioRecordingUrl: audioUrl,
        recordingDuration: Duration(
          minutes: 1,
        ), // Based on your UI showing 1 minute recording
      );

      // Set required fields on the EmergencyRequest base class
      sosRequest.userId = userId;
      sosRequest.userName = userName;
      sosRequest.userPhone = userPhone;
      sosRequest.timestamp = DateTime.now();
      sosRequest.location = GeoPoint(location.latitude, location.longitude);
      sosRequest.locationName = await _getLocationName(location);
      sosRequest.type = emergencyType;
      sosRequest.status = RequestStatus.active;
      sosRequest.guardianIds = await _getGuardianIds();

      // Step 4: Save to Firestore
      final requestId = await _saveRequestToFirestore(sosRequest);
      sosRequest.id = requestId;

      // Step 5: Notify guardians
      await _notifyGuardians(sosRequest);

      emit(RequestCreated(sosRequest));

      // Start timeout timer
      _startRequestTimer(requestId);
    } catch (e) {
      emit(RequestError('Failed to process SOS request: $e'));
    }
  }
}
