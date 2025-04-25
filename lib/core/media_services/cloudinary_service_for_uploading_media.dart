import 'dart:developer';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

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
}
