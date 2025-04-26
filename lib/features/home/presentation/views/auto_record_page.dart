// ignore_for_file: use_build_context_synchronously

import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/manager/auto_record_cubit/auto_record_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';

class AutoRecordPage extends StatelessWidget {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;
  final String requestType;

  const AutoRecordPage({
    super.key,
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
    required this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AutoRecordCubit()..initRecorder(),
      child: _AutoRecordContent(
        emergencyType: emergencyType,
        frontPhotoPath: frontPhotoPath,
        backPhotoPath: backPhotoPath,
        requestType: requestType,
      ),
    );
  }
}

class _AutoRecordContent extends StatelessWidget with WidgetsBindingObserver {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;
  final String requestType;

  _AutoRecordContent({
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
    required this.requestType,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  void _navigateToEmergencyCalling(BuildContext context, String audioPath) {
    context.pushReplacement(
      '/emergency-calling',
      extra: {
        'emergencyType': emergencyType,
        'frontPhotoPath': frontPhotoPath,
        'backPhotoPath': backPhotoPath,
        'audioPath': audioPath,
        'requestType': requestType,
      },
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Recording?'),
          content: const Text(
            'If you leave now, your recording will be lost. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Handle app lifecycle changes if needed
      // This might need to be moved to a different component as StatelessWidget
      // doesn't naturally have lifecycle methods
    }
  }

  Widget _buildErrorScreen(BuildContext context, AutoRecordState state) {
    final cubit = context.read<AutoRecordCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recording Error',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Audio Recording Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: Helper.getResponsiveHeight(context, height: 61)),
              ElevatedButton(
                onPressed: () => cubit.initRecorder(),
                child: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  cubit.skipRecording();
                  _navigateToEmergencyCalling(context, '');
                },
                child: const Text('Continue Without Audio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioWaveform(AutoRecordState state, bool isPaused) {
    if (!state.isRecording) {
      return Center(
        child: Text(
          'Ready to record',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    // Simple visualization effect - replace with actual visualization in production
    return CustomPaint(
      painter: WaveformPainter(
        progress: state.recordingDuration,
        isRecording: state.isRecording && !isPaused,
      ),
    );
  }

  Widget _buildBody(BuildContext context, AutoRecordState state) {
    final cubit = context.read<AutoRecordCubit>();
    final isPaused = cubit.isRecorderPaused;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(
              value: cubit.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                state.isRecording ? Colors.red : Colors.grey,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Countdown text
          Text(
            'Recording: ${cubit.formatDuration()} / ${cubit.formatTotalDuration()}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Message container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Audio recording will complete in ${60 - state.recordingDuration} seconds',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please stay on this page to avoid cancellation',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Audio visualization
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                state.isInitialized
                    ? _buildAudioWaveform(state, isPaused)
                    : const Center(child: CircularProgressIndicator()),
          ),

          const SizedBox(height: 40),

          // Recording button and status
          Column(
            children: [
              GestureDetector(
                onTap:
                    state.isInitialized ? cubit.pauseOrResumeRecording : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        state.isRecording
                            ? (isPaused ? Colors.grey[400] : Colors.red[400])
                            : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      state.isRecording
                          ? (isPaused ? Icons.mic_off : Icons.mic)
                          : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cubit.formatDuration(),
                style: TextStyle(
                  color: state.isRecording ? Colors.red[400] : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.isRecording
                    ? (isPaused
                        ? 'Recording paused'
                        : 'Recording in progress...')
                    : 'Initializing...',
                style: TextStyle(
                  color:
                      state.isRecording
                          ? (isPaused ? Colors.grey[700] : Colors.red)
                          : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutoRecordCubit, AutoRecordState>(
      listener: (context, state) {
        // Handle navigation when recording is complete
        if (state.isRecordingComplete) {
          _navigateToEmergencyCalling(context, state.audioPath);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AutoRecordCubit>();

        if (state.hasError) {
          return _buildErrorScreen(context, state);
        }

        return WillPopScope(
          onWillPop: () async {
            // Show confirmation dialog before allowing back navigation
            final shouldPop = await _showExitConfirmationDialog(context);
            return shouldPop ?? false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                  final shouldExit = await _showExitConfirmationDialog(context);
                  if (shouldExit == true) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const Text(
                'Audio Recording',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () {
                    cubit.skipRecording();
                    _navigateToEmergencyCalling(context, '');
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }
}

// Custom painter for audio waveform visualization
class WaveformPainter extends CustomPainter {
  final int progress;
  final bool isRecording;

  WaveformPainter({required this.progress, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isRecording ? Colors.red.withOpacity(0.7) : Colors.grey
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final center = height / 2;

    final path = Path();
    path.moveTo(0, center);

    // Create a semi-random waveform based on progress
    for (double i = 0; i < width; i += 5) {
      // Create a pseudo-random height based on position and progress
      final seed = (i + progress * 10) % 100;
      final amplitude = isRecording ? (20 + (seed % 30)) : 5;

      final y = center + ((seed.toInt().isEven) ? amplitude : -amplitude);
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);

    // Draw horizontal center line
    final centerPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, center), Offset(width, center), centerPaint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRecording != isRecording;
  }
}
