import 'dart:async';
import 'package:app/features/alert_request/services/video_recording_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  final bool isVideo;

  const CameraView({super.key, this.isVideo = false});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final VideoRecordingService _videoService = VideoRecordingService();
  late CameraController _cameraController;
  bool _isReady = false;
  bool _isFrontCamera = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: widget.isVideo,
      );

      await _cameraController.initialize();

      if (widget.isVideo) {
        await _videoService.initializeCamera();
      }

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _switchCamera() async {
    try {
      final cameras = await availableCameras();
      final newCameraIndex = _isFrontCamera ? 0 : 1;

      if (newCameraIndex >= cameras.length) {
        return;
      }

      await _cameraController.dispose();

      _cameraController = CameraController(
        cameras[newCameraIndex],
        ResolutionPreset.high,
        enableAudio: widget.isVideo,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _isFrontCamera = !_isFrontCamera;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  void _startRecording() async {
    if (!widget.isVideo || _isRecording) return;

    try {
      await _videoService.startRecording();

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start a timer to track recording duration
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<String?> _stopRecording() async {
    if (!widget.isVideo || !_isRecording) return null;

    try {
      _timer.cancel();
      final videoPath = await _videoService.stopRecording(context);

      setState(() {
        _isRecording = false;
      });

      return videoPath;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<String?> _takePicture() async {
    if (!_isReady || widget.isVideo) return null;

    try {
      final XFile image = await _cameraController.takePicture();
      return image.path;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cameraController.dispose();
    if (widget.isVideo) {
      _videoService.dispose();
      if (_isRecording) {
        _timer.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController),
          ),

          // UI Controls
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(_recordingDuration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isFrontCamera
                              ? Icons.camera_rear
                              : Icons.camera_front,
                          color: Colors.white,
                        ),
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Capture Button
                      GestureDetector(
                        onTap: () async {
                          if (widget.isVideo) {
                            if (_isRecording) {
                              // Stop recording and return video path
                              final videoPath = await _stopRecording();
                              if (videoPath != null) {
                                if (mounted) {
                                  Navigator.pop(context, videoPath);
                                }
                              }
                            } else {
                              // Start recording
                              _startRecording();
                            }
                          } else {
                            // Take a picture and return the image path
                            final imagePath = await _takePicture();
                            if (imagePath != null && mounted) {
                              Navigator.pop(context, imagePath);
                            }
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Container(
                              width: _isRecording ? 30 : 70,
                              height: _isRecording ? 30 : 70,
                              decoration: BoxDecoration(
                                shape:
                                    _isRecording
                                        ? BoxShape.rectangle
                                        : BoxShape.circle,
                                color: Colors.white,
                                borderRadius:
                                    _isRecording
                                        ? BorderRadius.circular(8)
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
