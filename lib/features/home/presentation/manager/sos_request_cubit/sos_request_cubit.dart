// request_cubit.dart
import 'dart:async';
import 'package:app/core/media_services/cloudinary_service_for_uploading_media.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';

part 'sos_request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  final CloudinaryStorageService _cloudinaryService =
      CloudinaryStorageService();
  RequestCubit() : super(RequestInitial());

  String? _frontPhotoPath;
  String? _backPhotoPath;
  String? _audioPath;
  Position? _currentPosition;
  String? _locationName;
  Timer? _requestTimer;
  EmergencyType? _emergencyType;
  String? _requestType;

  // Getters for state data
  String? get frontPhotoPath => _frontPhotoPath;
  String? get backPhotoPath => _backPhotoPath;
  String? get audioPath => _audioPath;
  Position? get currentPosition => _currentPosition;
  String? get locationName => _locationName;
  EmergencyType? get emergencyType => _emergencyType;
  String? get requestType => _requestType;

  // Initialize location tracking
  Future<void> initializeLocation() async {
    emit(RequestLocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const RequestLocationError('Location services are disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const RequestLocationError('Location permission denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          const RequestLocationError('Location permissions permanently denied'),
        );
        return;
      }

      // Start tracking location
      _currentPosition = await Geolocator.getCurrentPosition();
      _locationName = await _getLocationName(_currentPosition!);

      emit(
        RequestLocationReady(
          position: _currentPosition!,
          locationName: _locationName!,
        ),
      );
    } catch (e) {
      emit(RequestLocationError('Error obtaining location: $e'));
    }
  }

  // Get location name from coordinates
  Future<String> _getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? ''}, ${place.country ?? 'Unknown'}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }

  // Check and request permissions
  Future<bool> checkAndRequestPermissions() async {
    emit(RequestCheckingPermissions());

    final locationPermission = await Permission.locationWhenInUse.request();
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    if (locationPermission != PermissionStatus.granted ||
        cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      emit(
        const RequestPermissionDenied(
          'All permissions are required for emergency services',
        ),
      );
      return false;
    }

    emit(RequestPermissionsGranted());
    return true;
  }

  // Set emergency type
  void setEmergencyType(EmergencyType type) {
    _emergencyType = type;
    emit(RequestEmergencyTypeSelected(type));
  }

  void setRequestType(String type) {
    _requestType = type;
    emit(RequestTypeSelected(type));
  }

  // Start front camera capture
  Future<void> startFrontCapture() async {
    if (_emergencyType == null) {
      emit(const RequestError('Emergency type not selected'));
      return;
    }

    emit(RequestCapturingFront());
  }

  // Front photo captured
  void frontPhotoCaptured(String path) {
    _frontPhotoPath = path;
    emit(RequestFrontCaptured(path));
  }

  // Start back camera capture
  void startBackCapture() {
    if (_frontPhotoPath == null) {
      emit(const RequestError('Front photo not taken yet'));
      return;
    }

    emit(RequestCapturingBack(_frontPhotoPath!));
  }

  // Back photo captured
  void backPhotoCaptured(String path) {
    _backPhotoPath = path;
    emit(RequestBackCaptured(_frontPhotoPath!, path));
  }

  // Start audio recording
  void startAudioRecording() {
    if (_frontPhotoPath == null || _backPhotoPath == null) {
      emit(const RequestError('Photos not captured yet'));
      return;
    }

    emit(RequestRecordingAudio(_frontPhotoPath!, _backPhotoPath!));
  }

  // Audio recording completed
  void audioRecordingCompleted(String? path) {
    _audioPath = path;
    emit(RequestAudioRecorded(_frontPhotoPath!, _backPhotoPath!, path));
  }

  // Skip audio recording
  void skipAudioRecording() {
    _audioPath = null;
    emit(RequestAudioRecorded(_frontPhotoPath!, _backPhotoPath!, null));
  }

  // Start emergency process
  Future<void> startEmergencyProcess() async {
    if (_emergencyType == null || _currentPosition == null) {
      emit(const RequestError('Missing emergency type or location'));
      return;
    }

    emit(RequestProcessing());

    // Create emergency SOS request
    try {
      // Here you would typically send your data to a backend service
      // For now we'll just emit a success state

      final requestId = 'emergency_${DateTime.now().millisecondsSinceEpoch}';

      emit(
        RequestSuccess(
          requestId: requestId,
          emergencyType: _emergencyType!,
          requestType: _requestType!,
          position: _currentPosition!,
          locationName: _locationName ?? 'Unknown location',
          frontPhotoPath: _frontPhotoPath,
          backPhotoPath: _backPhotoPath,
          audioPath: _audioPath,
        ),
      );

      // Start timer for request expiration if needed
      _startRequestTimer(requestId);
    } catch (e) {
      emit(RequestError('Failed to process emergency request: $e'));
    }
  }

  // Reset request state
  void resetRequest() {
    _frontPhotoPath = null;
    _backPhotoPath = null;
    _audioPath = null;
    _emergencyType = null;
    _requestType = null;
    _requestTimer?.cancel();
    _requestTimer = null;

    emit(RequestInitial());
  }

  // Start emergency flow directly
  Future<bool> startSosRequest(
    BuildContext context, {
    EmergencyType? type,
    String? requestType,
  }) async {
    if (type != null) {
      setEmergencyType(type);
    } else if (_emergencyType == null) {
      emit(const RequestError('Emergency type not selected'));
      return false;
    }
    if (requestType != null) {
      setRequestType(requestType);
    } else if (_emergencyType == null) {
      emit(const RequestError('request type not selected'));
      return false;
    }
    // Check permissions
    final hasPermissions = await checkAndRequestPermissions();
    if (!hasPermissions) return false;

    // Check location
    if (_currentPosition == null) {
      await initializeLocation();
      if (_currentPosition == null) return false;
    }

    // Start front capture
    emit(RequestReadyForCapture());
    return true;
  }

  void _startRequestTimer(String? requestId) {
    _requestTimer?.cancel();
    _requestTimer = Timer(const Duration(minutes: 30), () {
      _closeRequest(requestId);
    });
  }

  Future<void> _closeRequest(String? requestId) async {
    // Close request logic here
    emit(RequestExpired());
  }

  @override
  Future<void> close() {
    _requestTimer?.cancel();
    return super.close();
  }

  Future<void> processSosRequest(
    EmergencyType emergencyType,
    String frontPhotoPath,
    String backPhotoPath,
    String audioPath,
    String requestType,
  ) async {
    emit(RequestLoading());

    try {
      if (_currentPosition == null) {
        emit(const RequestError('Location is not available'));
        return;
      }

      final userId = FirebaseFirestore.instance.app.options.projectId;

      // Convert Position to GeoPoint for Firestore
      final GeoPoint location = GeoPoint(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Upload media files to Cloudinary and create report in Firestore
      final mediaUrls = await _cloudinaryService
          .uploadEmergencyMediaAndCreateReport(
            emergencyType: emergencyType.name,
            frontPhotoPath: frontPhotoPath,
            backPhotoPath: backPhotoPath,
            audioPath: audioPath,
            userId: userId,
            location: location,
            locationName: _locationName ?? 'Unknown location',
            requestType: requestType,
          );
      final Duration? audioDuration = await getAudioDuration(
        mediaUrls['audioUrl']!,
      );
      // Create a SOSRequest object
      final SOSRequest request = SOSRequest(
        userId: userId,
        id: mediaUrls['reportId']!,
        type: emergencyType,
        location: location,
        locationName: _locationName ?? 'Unknown location',
        frontCameraPhotoUrl: mediaUrls['frontPhotoUrl']!,
        backCameraPhotoUrl: mediaUrls['backPhotoUrl']!,
        audioRecordingUrl: mediaUrls['audioUrl'] ?? '',
        status: RequestStatus.inProgress,
        guardianIds: [],
        recordingDuration: audioDuration!,
      );

      emit(RequestCreated(request));

      // Start timer for request expiration if needed
      _startRequestTimer(request.id);
    } catch (e) {
      emit(RequestError('Failed to process emergency request: $e'));
    }
  }

  Future<Duration?> getAudioDuration(String audioUrl) async {
    final player = AudioPlayer();

    try {
      await player.setUrl(audioUrl); // Load from Cloudinary URL
      Duration? duration = player.duration;
      return duration;
    } catch (e) {
      return null;
    } finally {
      await player.dispose(); // Always dispose
    }
  }

  // Method to handle when a guardian accepts the emergency request
  Future<void> handleEmergencyAccepted(
    String requestId,
    String guardianId,
  ) async {
    try {
      // Update Firestore to mark request as accepted
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(requestId)
          .update({
            'status': 'accepted',
            'accepted_by': guardianId,
            'accepted_at': FieldValue.serverTimestamp(),
          });

      // Get the updated request
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('reports')
              .doc(requestId)
              .get();

      if (docSnapshot.exists) {
        // Create a SOSRequest object from the Firestore data
        // You'll need to implement a fromFirestore factory constructor
        // For now, we'll create a minimal object with the required data
        final request = SOSRequest(
          id: requestId,
          userId: '', // Provide the actual userId if available
          type: _emergencyType!,
          location:
              _currentPosition != null
                  ? GeoPoint(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  )
                  : const GeoPoint(
                    0,
                    0,
                  ), // Provide actual location if available
          locationName: _locationName ?? 'Unknown location',
          status: RequestStatus.inProgress,
          guardianIds: [],
          frontCameraPhotoUrl: '',
          backCameraPhotoUrl: '',
          audioRecordingUrl: '',
          recordingDuration: Duration.zero,
        );

        emit(RequestAccepted(guardianId: guardianId, request: request));
      }
    } catch (e) {
      emit(RequestError('Failed to handle emergency acceptance: $e'));
    }
  }
}
