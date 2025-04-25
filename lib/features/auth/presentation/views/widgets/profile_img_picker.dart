import 'dart:developer';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/features/auth/presentation/manager/profile_image_cubit/profile_image_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImgPicker extends StatelessWidget {
  const ProfileImgPicker({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return BlocBuilder<ProfileImageCubit, ProfileImageState>(
      builder: (context, state) {
        log("Current ProfileImageState: $state");
        return Padding(
          padding: EdgeInsets.only(top: 0.01 * h, bottom: 0.02 * h),
          child: GestureDetector(
            onTap: () => _showImageSourceSheet(context),
            child: CircleAvatar(
              radius: 0.13 * w,
              backgroundColor: kNeutral100,
              child:
                  state is ProfileImageLoaded
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(0.13 * w),
                        child: Image.file(
                          state.imageFile,
                          width: 0.26 * w,
                          height: 0.26 * w,
                          fit: BoxFit.cover,
                        ),
                      )
                      : SvgPicture.asset(
                        AssetsData.uploadPicIcon,
                        width: 0.1 * w,
                      ),
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  GoRouter.of(context).pop();
                  log('Camera selected');
                  context.read<ProfileImageCubit>().pickImage(
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  GoRouter.of(context).pop();
                  log('Gallery selected');
                  context.read<ProfileImageCubit>().pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
    );
  }
}
