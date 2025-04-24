part of 'profile_image_cubit.dart';

@immutable
sealed class ProfileImageState {}

class ProfileImageInitial extends ProfileImageState {}

class ProfileImageLoading extends ProfileImageState {}

class ProfileImageLoaded extends ProfileImageState {
  final File imageFile;
  final String? imageUrl;

  ProfileImageLoaded({required this.imageFile, this.imageUrl});
}

class ProfileImageFailure extends ProfileImageState {
  final String error;
  ProfileImageFailure(this.error);
}
