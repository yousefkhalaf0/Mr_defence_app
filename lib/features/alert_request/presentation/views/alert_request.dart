import 'dart:developer';
import 'dart:io';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/features/alert_request/presentation/manager/emergency_request_cubit/emergency_request_cubit.dart';
import 'package:app/features/alert_request/presentation/views/widget/action_button.dart';
import 'package:app/features/alert_request/presentation/views/widget/info_card.dart';
import 'package:app/features/alert_request/presentation/views/widget/media_preview_widget.dart';
import 'package:app/features/alert_request/presentation/views/widget/upload_progress_page.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:go_router/go_router.dart';

class EmergencyRequestView extends StatefulWidget {
  final EmergencyType emergencyType;

  const EmergencyRequestView({super.key, required this.emergencyType});

  @override
  State<EmergencyRequestView> createState() => _EmergencyRequestViewState();
}

class _EmergencyRequestViewState extends State<EmergencyRequestView> {
  final TextEditingController _descriptionController = TextEditingController();
  String _currentDescription = '';
  final ImagePicker _picker = ImagePicker();
  List<File> photoFiles = [];
  List<File> videoFiles = [];
  String? audioFilePath;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    _currentDescription =
        'I have a ${widget.emergencyType.name.toLowerCase()} problem';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyRequestCubit>().getLocationData();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDescription(String value) {
    setState(() {
      _currentDescription =
          value.isEmpty
              ? 'I have a ${widget.emergencyType.name.toLowerCase()} problem'
              : value;
    });
  }

  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        photoFiles.add(File(photo.path));
      });
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) {
      setState(() {
        videoFiles.add(File(video.path));
      });
    }
  }

  void _showMediaPreview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MediaPreviewPage(photos: photoFiles, videos: videoFiles),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        photoFiles = result['photos'] ?? photoFiles;
        videoFiles = result['videos'] ?? videoFiles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyRequestCubit, EmergencyRequestState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.isSubmitting || state.isSuccess) {
          return UploadProgressPage(
            progress: state.uploadProgress,
            message: state.progressMessage,
            isComplete: state.isSuccess,
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Helper.getResponsiveWidth(context, width: 18),
                vertical: Helper.getResponsiveHeight(context, height: 25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        size: Helper.getResponsiveFontSize(
                          context,
                          fontSize: 25,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  Text(
                    'Emergency Request',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xff263238),
                      fontWeight: FontWeight.w600,
                      fontSize: Helper.getResponsiveFontSize(
                        context,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 15),
                  ),
                  // Location Card
                  InfoCard(
                    icon: AssetsData.locationIcon,
                    iconColor: Colors.red,
                    title: state.locationName ?? 'Getting location...',
                    subtitle: state.locationCoordinates ?? '',
                    showTextField: false,
                    descriptionController: _descriptionController,
                    onDescriptionChanged: (value) {
                      _descriptionController.text = value;
                    },
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 9),
                  ),

                  // Date and Time Card
                  InfoCard(
                    icon: AssetsData.alertDateIcon,
                    iconColor: Colors.red,
                    title: 'Date & Time',
                    subtitle: DateFormat(
                      'MM/dd/yyyy, hh:mm:ss a',
                    ).format(DateTime.now()),
                    showTextField: false,
                    descriptionController: _descriptionController,
                    onDescriptionChanged: (value) {
                      _descriptionController.text = value;
                    },
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 9),
                  ),

                  // Emergency Type Card
                  InfoCard(
                    icon: widget.emergencyType.iconPath,
                    iconColor: Colors.red,
                    backgroundColor: widget.emergencyType.backgroundColor,
                    title: widget.emergencyType.name,
                    subtitle:
                        _currentDescription, // Use the state variable for real-time updates
                    showTextField: true,
                    descriptionController: _descriptionController,
                    onDescriptionChanged: _updateDescription,
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 9),
                  ),
                  // Media Capture Row
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          icon: AssetsData.videoIcon,
                          label: 'Footage',
                          subtitle: 'Record Live video',
                          onTap: _recordVideo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          icon: AssetsData.camerIcon,
                          label: 'Picture',
                          subtitle: 'Upload Live photo',
                          onTap: _capturePhoto,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 15),
                  ),

                  // Who happened section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who happened?',
                        style: TextStyle(
                          fontSize: Helper.getResponsiveFontSize(
                            context,
                            fontSize: 15,
                          ),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(
                        height: Helper.getResponsiveHeight(context, height: 9),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffCECECE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildSelectionButton(
                              icon: AssetsData.personIcon,
                              label: 'For me',
                              isSelected: state.isForMe,
                              onTap:
                                  () => context
                                      .read<EmergencyRequestCubit>()
                                      .toggleIsForMe(true),
                            ),
                            SizedBox(
                              width: Helper.getResponsiveWidth(
                                context,
                                width: 10,
                              ),
                            ),
                            _buildSelectionButton(
                              icon: AssetsData.otherIcon,
                              label: 'other people',
                              isSelected: !state.isForMe,
                              onTap:
                                  () => context
                                      .read<EmergencyRequestCubit>()
                                      .toggleIsForMe(false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 15),
                  ),
                  // Media preview if any media is captured
                  if (photoFiles.isNotEmpty || videoFiles.isNotEmpty)
                    InkWell(
                      onTap: _showMediaPreview,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachments',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: Helper.getResponsiveFontSize(
                                context,
                                fontSize: 15,
                              ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(
                            height: Helper.getResponsiveHeight(
                              context,
                              height: 9,
                            ),
                          ),
                          Container(
                            height: Helper.getResponsiveHeight(
                              context,
                              height: 70,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCECECE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Media captured',
                                        style: TextStyle(
                                          fontSize:
                                              Helper.getResponsiveFontSize(
                                                context,
                                                fontSize: 16,
                                              ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      Text(
                                        '${photoFiles.length} photos, ${videoFiles.length} videos',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize:
                                              Helper.getResponsiveFontSize(
                                                context,
                                                fontSize: 12,
                                              ),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(
                                    Helper.getResponsiveWidth(
                                      context,
                                      width: 12,
                                    ),
                                  ),
                                  width: Helper.getResponsiveWidth(
                                    context,
                                    width: 42,
                                  ),
                                  height: Helper.getResponsiveHeight(
                                    context,
                                    height: 42,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      222,
                                      255,
                                      255,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    size: Helper.getResponsiveWidth(
                                      context,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 15),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: Helper.getResponsiveWidth(context, width: 199),
                      child: ElevatedButton(
                        onPressed:
                            state.isLoading
                                ? null
                                : () {
                                  if (state.locationName != null) {
                                    context
                                        .read<EmergencyRequestCubit>()
                                        .submitEmergencyRequest(
                                          emergencyType: widget.emergencyType,
                                          description:
                                              _descriptionController.text,
                                          photoFiles: photoFiles,
                                          videoFiles: videoFiles,
                                          audioFile:
                                              audioFilePath != null
                                                  ? File(audioFilePath!)
                                                  : null,
                                          requestType: RequestType.alert,
                                        );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Waiting for location data...',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            state.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Helper.getResponsiveHeight(context, height: 20),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionButton({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFFF5A5F)
                  : const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(
                Helper.getResponsiveWidth(context, width: 12),
              ),
              width: Helper.getResponsiveWidth(context, width: 42),
              height: Helper.getResponsiveHeight(context, height: 42),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(76, 38, 50, 56),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(
                icon,

                colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 0, 0, 0),
                  BlendMode.srcIn,
                ),
                width: Helper.getResponsiveWidth(context, width: 4),
                height: Helper.getResponsiveHeight(context, height: 4),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kBackGroundColor : Color(0xff313A51),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
