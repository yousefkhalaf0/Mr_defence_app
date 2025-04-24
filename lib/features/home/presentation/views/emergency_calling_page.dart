// import 'dart:io';
// import 'package:app/core/media_services/cloudinary_service_for_uploading_media.dart';
// import 'package:app/features/home/presentation/manager/sos_request_cubit/sos_request_cubit.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:app/features/home/data/emergency_type_data_model.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class EmergencyCallingPage extends StatefulWidget {
//   final EmergencyType emergencyType;
//   final String frontPhotoPath;
//   final String backPhotoPath;
//   final String audioPath;

//   const EmergencyCallingPage({
//     Key? key,
//     required this.emergencyType,
//     required this.frontPhotoPath,
//     required this.backPhotoPath,
//     required this.audioPath,
//   }) : super(key: key);

//   @override
//   State<EmergencyCallingPage> createState() => _EmergencyCallingPageState();
// }

// class _EmergencyCallingPageState extends State<EmergencyCallingPage> {
//   final CloudinaryStorageService _cloudinaryService =
//       CloudinaryStorageService();
//   bool _isUploading = false;
//   bool _uploadComplete = false;
//   String _reportId = '';
//   String _errorMessage = '';
//   double _uploadProgress = 0.0;
//   String _currentUploadStep = '';

//   @override
//   void initState() {
//     super.initState();
//     _uploadEmergencyFiles();
//   }

//   Future<Position> _getCurrentLocation() async {
//     try {
//       // Get the current position
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       // Return as a formatted string
//       return position;
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       // Return default location if unable to get current location
//       return '[0° N, 0° E]' as Position;
//     }
//   }

//   Future<String> _getUserId() async {
//     // Get user ID from SharedPreferences or other storage
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId') ?? 'unknown_user';
//   }

//   Future<void> _uploadEmergencyFiles() async {
//     if (!mounted) return;

//     setState(() {
//       _isUploading = true;
//       _currentUploadStep = 'Preparing to upload...';
//       _uploadProgress = 0.1;
//     });

//     try {
//       // Get user ID and location
//       final userId = await _getUserId();
//       final location = await _getCurrentLocation();

//       // Upload all media files and create report document
//       final result = await _cloudinaryService
//           .uploadEmergencyMediaAndCreateReport(
//             emergencyType: widget.emergencyType.name,
//             frontPhotoPath: widget.frontPhotoPath,
//             backPhotoPath: widget.backPhotoPath,
//             audioPath: widget.audioPath,
//             userId: userId,
//             location: GeoPoint(location.latitude, location.longitude),
//             locationName: locationName ,
//           );

//       setState(() {
//         _currentUploadStep = 'Finalizing report...';
//         _uploadProgress = 0.9;
//       });

//       // Store report ID for reference
//       _reportId = result['reportId']!;

//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//           _uploadComplete = true;
//           _uploadProgress = 1.0;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//           _errorMessage = 'Failed to upload files: $e';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Emergency Report'),
//         backgroundColor: Colors.red,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Display upload status
//               if (_isUploading) _buildUploadingState(),

//               // Display success message
//               if (_uploadComplete) _buildUploadCompleteState(),

//               // Display error message if any
//               if (_errorMessage.isNotEmpty) _buildErrorState(),

//               const Spacer(),

//               // Action buttons
//               if (_uploadComplete)
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to home or report details
//                     Navigator.of(context).popUntil((route) => route.isFirst);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Return to Home',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),

//               if (_errorMessage.isNotEmpty)
//                 ElevatedButton(
//                   onPressed: _uploadEmergencyFiles,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Retry Upload',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUploadingState() {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         const CircularProgressIndicator(color: Colors.red),
//         const SizedBox(height: 24),
//         Text(
//           _currentUploadStep,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         LinearProgressIndicator(value: _uploadProgress),
//         const SizedBox(height: 8),
//         Text(
//           '${(_uploadProgress * 100).toInt()}%',
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 32),
//         const Text(
//           'Please wait while we upload your emergency report. This may take a moment depending on your connection.',
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildUploadCompleteState() {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         const Icon(Icons.check_circle, color: Colors.green, size: 80),
//         const SizedBox(height: 24),
//         const Text(
//           'Report Submitted Successfully',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Your emergency report #${_reportId.substring(0, 8)} has been submitted and is being processed.',
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 16),
//         ),
//         const SizedBox(height: 32),
//         const Text(
//           'Emergency services have been notified and will respond as soon as possible.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 24),
//         _buildMediaPreview(),
//       ],
//     );
//   }

//   Widget _buildErrorState() {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         const Icon(Icons.error_outline, color: Colors.red, size: 80),
//         const SizedBox(height: 24),
//         const Text(
//           'Upload Failed',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         Text(
//           _errorMessage,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.red),
//         ),
//         const SizedBox(height: 32),
//         const Text(
//           'Please check your internet connection and try again.',
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildMediaPreview() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildImageThumbnail(widget.frontPhotoPath, 'Front'),
//         const SizedBox(width: 16),
//         _buildImageThumbnail(widget.backPhotoPath, 'Back'),
//         if (widget.audioPath.isNotEmpty) ...[
//           const SizedBox(width: 16),
//           _buildAudioIndicator(),
//         ],
//       ],
//     );
//   }

//   Widget _buildImageThumbnail(String path, String label) {
//     return Column(
//       children: [
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(File(path), fit: BoxFit.cover),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   Widget _buildAudioIndicator() {
//     return Column(
//       children: [
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey[200],
//           ),
//           child: const Icon(Icons.mic, size: 40),
//         ),
//         const SizedBox(height: 4),
//         const Text('Audio', style: TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }
