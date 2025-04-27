import 'dart:io';
import 'package:app/core/utils/router.dart';
import 'package:app/features/alert_request/presentation/manager/emergency_request_cubit/emergency_request_cubit.dart';
import 'package:app/features/alert_request/presentation/views/widget/media_preview_widget.dart';
import 'package:app/features/alert_request/presentation/views/widget/upload_progress_page.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final ImagePicker _picker = ImagePicker();
  List<File> photoFiles = [];
  List<File> videoFiles = [];
  String? audioFilePath;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    // Initialize the cubit and fetch location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyRequestCubit>().getLocationData();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

  void _showMediaPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MediaPreviewPage(photos: photoFiles, videos: videoFiles),
      ),
    );
  }

  void _navigateToHome() {
    // Navigate to home using GoRouter and replace the current page in the stack
    GoRouter.of(context).push(AppRouter.kHomeView);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyRequestCubit, EmergencyRequestState>(
      listener: (context, state) {
        // Show error messages
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        // Show progress indicator page when submitting
        if (state.isSubmitting || state.isSuccess) {
          return UploadProgressPage(
            progress: state.uploadProgress,
            message: state.progressMessage,
            isComplete: state.isSuccess,
            onComplete: _navigateToHome,
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Emergency Request',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location Card
                  _buildInfoCard(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: state.locationName ?? 'Getting location...',
                    subtitle: state.locationCoordinates ?? '',
                  ),

                  const SizedBox(height: 12),

                  // Date and Time Card
                  _buildInfoCard(
                    icon: Icons.access_time,
                    iconColor: Colors.red,
                    title: 'Date & Time',
                    subtitle: DateFormat(
                      'MM/dd/yyyy, hh:mm:ss a',
                    ).format(DateTime.now()),
                  ),

                  const SizedBox(height: 12),

                  // Emergency Type Card
                  _buildInfoCard(
                    icon: Icons.medical_services,
                    iconColor: widget.emergencyType.backgroundColor,
                    title: widget.emergencyType.name,
                    subtitle:
                        _descriptionController.text.isEmpty
                            ? 'I have a ${widget.emergencyType.name.toLowerCase()} problem'
                            : _descriptionController.text,
                    showTextField: true,
                  ),

                  const SizedBox(height: 16),

                  // Media Capture Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.videocam,
                          label: 'Footage',
                          subtitle: 'Record Live video',
                          onTap: _recordVideo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'Picture',
                          subtitle: 'Upload Live photo',
                          onTap: _capturePhoto,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Who happened section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Who happened?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSelectionButton(
                              icon: Icons.person,
                              label: 'For me',
                              isSelected: state.isForMe,
                              onTap:
                                  () => context
                                      .read<EmergencyRequestCubit>()
                                      .toggleIsForMe(true),
                            ),
                            _buildSelectionButton(
                              icon: Icons.people,
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

                  const SizedBox(height: 24),

                  // Media preview if any media is captured
                  if (photoFiles.isNotEmpty || videoFiles.isNotEmpty)
                    InkWell(
                      onTap: _showMediaPreview,
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Media captured',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${photoFiles.length} photos, ${videoFiles.length} videos',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Send Button
                  ElevatedButton(
                    onPressed:
                        state.isLoading
                            ? null
                            : () {
                              if (state.locationName != null) {
                                context
                                    .read<EmergencyRequestCubit>()
                                    .submitEmergencyRequest(
                                      emergencyType: widget.emergencyType,
                                      description: _descriptionController.text,
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

                  const SizedBox(height: 12),

                  // Emergency timer text
                  Center(
                    child: Text(
                      'Emergency Alert triggered in 15s . . .',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showTextField = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
          if (showTextField)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Add more about . . .',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // This will trigger a rebuild with the new description
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.pink : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
