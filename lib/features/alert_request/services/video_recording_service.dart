import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VideoRecordingService {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _videoPath;
  DateTime? _recordingStartTime;
  final Duration _minDuration = const Duration(minutes: 1);

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _controller = CameraController(
        _cameras[0], // Use the first camera (usually back camera)
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _controller.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (!_isInitialized || _cameras.length < 2) return;

    final lensDirection = _controller.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.back) {
      newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    await _controller.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller.initialize();
  }

  Future<void> startRecording() async {
    if (!_isInitialized || _isRecording) return;

    try {
      // Create a temporary file path
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller.startVideoRecording();
      _recordingStartTime = DateTime.now();
      _isRecording = true;
      _videoPath = filePath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording(BuildContext context) async {
    if (!_isInitialized || !_isRecording) return null;

    try {
      // Check if the minimum recording duration has been met
      final Duration recordingDuration = DateTime.now().difference(
        _recordingStartTime!,
      );

      if (recordingDuration < _minDuration) {
        final int remainingSeconds =
            (_minDuration - recordingDuration).inSeconds;

        // Show a dialog to inform the user about the minimum duration
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Recording in progress'),
                content: Text(
                  'You need to record for at least 1 minute. Please continue recording for $remainingSeconds more seconds.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );

        return null;
      }

      // Stop recording if minimum duration is met
      final XFile videoFile = await _controller.stopVideoRecording();
      _isRecording = false;

      return videoFile.path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _controller.dispose();
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  CameraController get controller => _controller;
}
