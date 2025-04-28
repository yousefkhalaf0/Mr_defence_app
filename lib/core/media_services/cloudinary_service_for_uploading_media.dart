import 'dart:developer';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryStorageService {
  final cloudinary = CloudinaryPublic(
    'mrdefencemedia',
    'ml_default',
    cache: false,
  );

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'Profile Images',
          resourceType: CloudinaryResourceType.Image,
          publicId: userId,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      log('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique ID for media files
  final _uuid = const Uuid();

  // Upload image to Cloudinary and update Firestore
  Future<String> uploadImage(String imagePath, String reportId) async {
    try {
      final fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
          folder: 'Report Images',
          publicId: fileName,
        ),
      );

      // Get the secure URL of the uploaded image
      final imageUrl = response.secureUrl;

      // Update Firestore with the image URL
      await _updateFirestoreWithMedia(reportId, 'pictures', imageUrl);

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload video to Cloudinary and update Firestore
  Future<String> uploadVideo(String videoPath, String reportId) async {
    try {
      final fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoPath,
          resourceType: CloudinaryResourceType.Video,
          folder: 'Report Videos',
          publicId: fileName,
        ),
      );

      // Get the secure URL of the uploaded video
      final videoUrl = response.secureUrl;

      // Update Firestore with the video URL
      await _updateFirestoreWithMedia(reportId, 'videos', videoUrl);

      return videoUrl;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      throw Exception('Failed to upload video: $e');
    }
  }

  // Upload audio to Cloudinary and update Firestore
  Future<String> uploadAudio(String audioPath, String reportId) async {
    try {
      if (audioPath.isEmpty) {
        return ''; // Return empty string if no audio was recorded
      }

      final fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioPath,
          resourceType: CloudinaryResourceType.Auto,
          folder: 'Report Audios',
          publicId: fileName,
        ),
      );

      // Get the secure URL of the uploaded audio
      final audioUrl = response.secureUrl;

      // Update Firestore with the audio URL
      await _updateFirestoreWithMedia(reportId, 'voice_records', audioUrl);

      return audioUrl;
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      throw Exception('Failed to upload audio: $e');
    }
  }

  // Update Firestore with media URL
  Future<void> _updateFirestoreWithMedia(
    String reportId,
    String mediaField,
    String mediaUrl,
  ) async {
    try {
      final reportRef = _firestore.collection('reports').doc(reportId);

      // Get the current document
      final docSnapshot = await reportRef.get();

      if (docSnapshot.exists) {
        // Check if the field exists and is already an array
        if (docSnapshot.data()!.containsKey(mediaField)) {
          // Add to existing array
          await reportRef.update({
            mediaField: FieldValue.arrayUnion([mediaUrl]),
          });
        } else {
          // Create new array with this media URL
          await reportRef.update({
            mediaField: [mediaUrl],
          });
        }
      } else {
        // Create new document with this media URL
        await reportRef.set({
          mediaField: [mediaUrl],
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error updating Firestore with media URL: $e');
      throw Exception('Failed to update Firestore: $e');
    }
  }

  // Upload all emergency media files and create report document
  Future<Map<String, String>> uploadEmergencyMediaAndCreateReport({
    required String emergencyType,
    required String frontPhotoPath,
    required String backPhotoPath,
    required String audioPath,

    required GeoPoint location,
    required String locationName,
    required String requestType,
  }) async {
    try {
      // Create a new report document with initial data
      final reportRef = _firestore.collection('reports').doc();
      final reportId = reportRef.id;
      final FirebaseFirestore _firestoreAuth = FirebaseFirestore.instance;
      final FirebaseAuth _auth = FirebaseAuth.instance;
      // Set initial report data
      await reportRef.set({
        'description': [],
        'location_name': locationName,
        'emergency_type': emergencyType,
        'occured_location': location,
        'receiver_guardians': [],
        'occured_time': FieldValue.serverTimestamp(),
        'request_type': requestType,
        'status': 'pending',
        'user_id': _auth.currentUser?.uid ?? 'unknown_user',
        'who_happened': true,
        'pictures': [],
        'videos': [],
        'voice_records': [],
      });

      // Upload front photo
      final frontPhotoUrl = await uploadImage(frontPhotoPath, reportId);

      // Upload back photo
      final backPhotoUrl = await uploadImage(backPhotoPath, reportId);

      // Upload audio if available
      String audioUrl = '';
      if (audioPath.isNotEmpty) {
        audioUrl = await uploadAudio(audioPath, reportId);
      }

      // Return all URLs in a map
      return {
        'reportId': reportId,
        'frontPhotoUrl': frontPhotoUrl,
        'backPhotoUrl': backPhotoUrl,
        'audioUrl': audioUrl,
      };
    } catch (e) {
      debugPrint('Error uploading emergency media: $e');
      throw Exception('Failed to upload emergency media: $e');
    }
  }

  // Fetch media from a specific report
  Future<Map<String, List<dynamic>>> getReportMedia(String reportId) async {
    try {
      final reportDoc =
          await _firestore.collection('reports').doc(reportId).get();

      if (!reportDoc.exists) {
        throw Exception('Report not found');
      }

      final data = reportDoc.data();

      return {
        'pictures': List<String>.from(data?['pictures'] ?? []),
        'videos': List<String>.from(data?['videos'] ?? []),
        'voice_records': List<String>.from(data?['voice_records'] ?? []),
      };
    } catch (e) {
      debugPrint('Error getting report media: $e');
      throw Exception('Failed to get report media: $e');
    }
  }
}
