import 'dart:io';
import 'package:app/core/media_services/cloudinary_service_for_uploading_media.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
part 'emergency_request_state.dart';

class EmergencyRequestCubit extends Cubit<EmergencyRequestState> {
  final CloudinaryStorageService _cloudinaryService =
      CloudinaryStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmergencyRequestCubit() : super(const EmergencyRequestState());

  Future<void> getLocationData() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'Location permissions are denied',
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Location permissions are permanently denied',
          ),
        );
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final locationName = '${place.locality ?? ''}, ${place.country ?? ''}';
        final coordinates = '${position.latitude}, ${position.longitude}';

        emit(
          state.copyWith(
            isLoading: false,
            locationName: locationName,
            locationCoordinates: coordinates,
            position: position,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error getting location: $e',
        ),
      );
    }
  }

  void toggleIsForMe(bool value) {
    emit(state.copyWith(isForMe: value));
  }

  Future<void> submitEmergencyRequest({
    required EmergencyType emergencyType,
    required String description,
    required List<File> photoFiles,
    required List<File> videoFiles,
    File? audioFile,
    required RequestType requestType,
  }) async {
    if (state.position == null) {
      emit(
        state.copyWith(
          errorMessage: 'Location data is not available',
          isSubmitting: false,
        ),
      );
      return;
    }

    // Set submission in progress
    emit(
      state.copyWith(
        isSubmitting: true,
        uploadProgress: 0.1,
        progressMessage: 'Preparing request...',
      ),
    );

    try {
      final userId = _auth.currentUser?.uid ?? 'unknown_user';
      final geoPoint = GeoPoint(
        state.position!.latitude,
        state.position!.longitude,
      );

      // Create a document reference with a new ID
      final reportRef = _firestore.collection('reports').doc();
      final reportId = reportRef.id;

      // Upload media files if available
      List<String> photoUrls = [];
      List<String> videoUrls = [];
      String? audioUrl;

      // Set progress for media upload initialization
      emit(
        state.copyWith(
          uploadProgress: 0.2,
          progressMessage: 'Uploading photos...',
        ),
      );

      // Upload photos
      int photoCount = 0;
      for (var photoFile in photoFiles) {
        try {
          final url = await _cloudinaryService.uploadImage(
            photoFile.path,
            reportId,
          );
          photoUrls.add(url);
          photoCount++;

          // Update progress based on photo upload completion
          double photoProgress = 0.2 + (0.3 * (photoCount / photoFiles.length));
          emit(
            state.copyWith(
              uploadProgress: photoProgress,
              progressMessage:
                  'Uploading photos (${photoCount}/${photoFiles.length})...',
            ),
          );
        } catch (e) {
          debugPrint('Error uploading photo: $e');
          // Continue with other photos even if one fails
        }
      }

      // Set progress for video upload
      emit(
        state.copyWith(
          uploadProgress: 0.5,
          progressMessage: 'Uploading videos...',
        ),
      );

      // Upload videos
      int videoCount = 0;
      for (var videoFile in videoFiles) {
        try {
          final url = await _cloudinaryService.uploadVideo(
            videoFile.path,
            reportId,
          );
          videoUrls.add(url);
          videoCount++;

          // Update progress based on video upload completion
          double videoProgress = 0.5 + (0.3 * (videoCount / videoFiles.length));
          emit(
            state.copyWith(
              uploadProgress: videoProgress,
              progressMessage:
                  'Uploading videos (${videoCount}/${videoFiles.length})...',
            ),
          );
        } catch (e) {
          debugPrint('Error uploading video: $e');
          // Continue with other videos even if one fails
        }
      }

      // Upload audio if available
      if (audioFile != null) {
        emit(
          state.copyWith(
            uploadProgress: 0.8,
            progressMessage: 'Uploading audio...',
          ),
        );

        try {
          audioUrl = await _cloudinaryService.uploadAudio(
            audioFile.path,
            reportId,
          );
        } catch (e) {
          debugPrint('Error uploading audio: $e');
          // Continue even if audio upload fails
        }
      }

      // Set progress for Firestore upload
      emit(
        state.copyWith(
          uploadProgress: 0.9,
          progressMessage: 'Saving report data...',
        ),
      );

      // Create the report document with corrected field names
      await reportRef.set({
        'emergency_type': emergencyType.name, // Corrected spelling
        'occurred_location': geoPoint, // Corrected spelling
        'occurred_time': FieldValue.serverTimestamp(), // Corrected spelling
        'request_type': requestType.name,
        'status': 'pending',
        'user_id': userId,
        'who_happened': state.isForMe,
        'pictures': photoUrls,
        'videos': videoUrls,
        'voice_records': audioUrl != null ? [audioUrl] : [],
        'location_name': state.locationName,
        'description': description,
        'receiver_guardians': [], // Corrected spelling
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update state with success
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          reportId: reportId,
          uploadProgress: 1.0,
          progressMessage: 'Report submitted successfully!',
        ),
      );
    } catch (e) {
      debugPrint('Error submitting emergency request: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to submit emergency request: $e',
          uploadProgress: 0,
        ),
      );
    }
  }
}
