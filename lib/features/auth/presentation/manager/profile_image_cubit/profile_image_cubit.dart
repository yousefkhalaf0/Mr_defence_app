import 'dart:developer';
import 'dart:io';
import 'package:app/core/media_services/cloudinary_service_for_uploading_media.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
part 'profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit() : super(ProfileImageInitial());

  final ImagePicker _picker = ImagePicker();
  final CloudinaryStorageService _cloudinaryService =
      CloudinaryStorageService();

  Future<void> pickImage(ImageSource source) async {
    log("Attempting to pick image from: $source");
    emit(ProfileImageLoading());

    try {
      if (source == ImageSource.gallery) {
        if (Platform.isAndroid) {
          // Check Android version
          if (int.parse(await getAndroidSdkVersion()) >= 33) {
            // Android 13+ uses Photos permission
            if (await Permission.photos.request().isGranted) {
              await _pickImageFromSource(source);
            } else {
              log("Photos permission denied");
              emit(ProfileImageFailure("Photos permission denied"));
            }
          } else {
            // Android 12 and below uses Storage permission
            if (await Permission.storage.request().isGranted) {
              await _pickImageFromSource(source);
            } else {
              log("Storage permission denied");
              emit(ProfileImageFailure("Storage permission denied"));
            }
          }
        } else {
          // iOS
          if (await Permission.photos.request().isGranted) {
            await _pickImageFromSource(source);
          } else {
            log("Photos permission denied");
            emit(ProfileImageFailure("Photos permission denied"));
          }
        }
      } else if (source == ImageSource.camera) {
        if (await Permission.camera.request().isGranted) {
          await _pickImageFromSource(source);
        } else {
          log("Camera permission denied");
          emit(ProfileImageFailure("Camera permission denied"));
        }
      }
    } catch (e) {
      log("Error in pickImage: $e");
      emit(ProfileImageFailure(e.toString()));
    }
  }

  Future<String> getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      try {
        return await DeviceInfoPlugin().androidInfo.then(
          (info) => info.version.sdkInt.toString(),
        );
      } catch (e) {
        log("Error getting Android SDK version: $e");
        return "0"; // Default to 0 if can't determine
      }
    }
    return "0";
  }

  // Helper method to pick image from source
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        log("Image picked successfully: ${pickedFile.path}");
        emit(ProfileImageLoaded(imageFile: File(pickedFile.path)));
      } else {
        log("No image selected");
      }
    } catch (e) {
      log("Error in _pickImageFromSource: $e");
      emit(ProfileImageFailure(e.toString()));
    }
  }

  Future<String?> uploadProfileImage(String userId) async {
    final state = this.state;
    if (state is ProfileImageLoaded) {
      try {
        emit(ProfileImageLoading());

        final imageUrl = await _cloudinaryService.uploadProfileImage(
          state.imageFile,
          userId,
        );

        if (imageUrl != null) {
          emit(
            ProfileImageLoaded(imageFile: state.imageFile, imageUrl: imageUrl),
          );
          return imageUrl;
        } else {
          emit(ProfileImageFailure('Failed to upload image'));
          return null;
        }
      } catch (e) {
        emit(ProfileImageFailure(e.toString()));
        return null;
      }
    }
    return null;
  }
}
