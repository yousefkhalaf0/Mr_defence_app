import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'your_cloud_name', // Replace with your Cloudinary cloud name
    'ml_default', // Upload preset - create this in your Cloudinary dashboard
    cache: false,
  );

  // Upload image to Cloudinary
  Future<String> uploadImage(String imagePath) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
          // Add folder and custom tags for organization
          folder: 'emergency_images',
          tags: ['emergency_app', 'photo'],
        ),
      );
      // Return the secure URL of the uploaded image
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload audio to Cloudinary
  Future<String> uploadAudio(String audioPath) async {
    try {
      if (audioPath.isEmpty) {
        return ''; // Return empty string if no audio was recorded
      }

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioPath,
          resourceType: CloudinaryResourceType.Auto,
          // Add folder and custom tags for organization
          folder: 'emergency_audio',
          tags: ['emergency_app', 'audio'],
        ),
      );
      // Return the secure URL of the uploaded audio
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      throw Exception('Failed to upload audio: $e');
    }
  }

  // Upload all emergency media files at once
  Future<Map<String, String>> uploadEmergencyMedia({
    required String frontPhotoPath,
    required String backPhotoPath,
    required String audioPath,
  }) async {
    try {
      // Upload front photo
      final frontPhotoUrl = await uploadImage(frontPhotoPath);

      // Upload back photo
      final backPhotoUrl = await uploadImage(backPhotoPath);

      // Upload audio if available
      String audioUrl = '';
      if (audioPath.isNotEmpty) {
        audioUrl = await uploadAudio(audioPath);
      }

      // Return all URLs in a map
      return {
        'frontPhotoUrl': frontPhotoUrl,
        'backPhotoUrl': backPhotoUrl,
        'audioUrl': audioUrl,
      };
    } catch (e) {
      debugPrint('Error uploading emergency media: $e');
      throw Exception('Failed to upload emergency media: $e');
    }
  }
}
