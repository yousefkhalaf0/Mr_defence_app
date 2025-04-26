// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/presentation/manager/auto_record_cubit/auto_record_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          // Message container
          Center(
            child: Container(
              width: Helper.getResponsiveWidth(context, width: 344),
              height: Helper.getResponsiveHeight(context, height: 89),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(237, 255, 255, 255),
                borderRadius: BorderRadius.circular(70),
              ),

              child: Text(
                'Audio recording will complete in ${60 - state.recordingDuration} seconds \nPlease stay on this page to avoid cancellation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kNeutral600,
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 13),
                ),
              ),
            ),
          ),

          SizedBox(height: Helper.getResponsiveHeight(context, height: 90)),

          // Audio visualization
          Container(
            height: Helper.getResponsiveHeight(context, height: 88),
            width: Helper.getResponsiveWidth(context, width: 320),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child:
                state.isInitialized
                    ? _buildAudioWaveform(state, isPaused)
                    : const Center(child: CircularProgressIndicator()),
          ),

          SizedBox(height: Helper.getResponsiveHeight(context, height: 10)),
          // Recording button and status
          Column(
            children: [
              GestureDetector(
                onTap:
                    state.isInitialized ? cubit.pauseOrResumeRecording : null,
                child: Container(
                  width: Helper.getResponsiveHeight(context, height: 110),
                  height: Helper.getResponsiveHeight(context, height: 110),
                  decoration: BoxDecoration(
                    color:
                        state.isRecording
                            ? (isPaused
                                ? Colors.grey[400]
                                : const Color(0xffE96A6A))
                            : Colors.grey[400],
                    shape: BoxShape.circle,
                    boxShadow: [
                      const BoxShadow(
                        color: Color.fromARGB(64, 0, 0, 0),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      state.isRecording
                          ? (isPaused ? AssetsData.micOff : AssetsData.micOn)
                          : AssetsData.micOn,
                      color: kBackGroundColor,
                      width: Helper.getResponsiveWidth(context, width: 44.48),
                      height: Helper.getResponsiveHeight(context, height: 69.9),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Helper.getResponsiveHeight(context, height: 8)),
              Text(
                cubit.formatDuration(),
                style: TextStyle(
                  color: state.isRecording ? Colors.red[400] : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Helper.getResponsiveHeight(context, height: 8)),
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
            backgroundColor: kBackGroundColor,
            appBar: AppBar(
              backgroundColor: kBackGroundColor,
              elevation: 0,

              title: Text(
                'Start recording',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final int progress;
  final bool isRecording;
  final Random _random = Random(42); // Fixed seed for initial rendering
  final List<double> _heightFactors = [];

  WaveformPainter({required this.progress, required this.isRecording}) {
    // Generate height factors if not already done
    if (_heightFactors.isEmpty) {
      // Pre-generate a set of irregular heights
      for (int i = 50; i < 200; i++) {
        _heightFactors.add(_random.nextDouble());
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isRecording ? Color(0xff354752) : Colors.grey.shade700
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final center = height / 2;

    // Draw vertical lines with varying heights
    final barWidth = 4.0;
    final spacing = 5.0;
    final numBars = (width / (barWidth + spacing)).floor();

    for (int i = 0; i < numBars; i++) {
      // Use progress to shift which heights we use
      final heightIndex = (i + progress) % _heightFactors.length;
      final heightFactor = _heightFactors[heightIndex];

      // Create truly irregular heights - some very short, some tall
      // Use a non-linear distribution to create more variation
      double lineHeight;
      if (heightFactor < 0.3) {
        // Short lines (30% chance) - make taller
        lineHeight = height * (0.15 + heightFactor * 0.2);
      } else if (heightFactor < 0.7) {
        // Medium lines (40% chance) - make taller
        lineHeight = height * (0.35 + (heightFactor - 0.3) * 0.3);
      } else {
        // Tall lines (30% chance) - make much taller
        lineHeight = height * (0.55 + (heightFactor - 0.7) * 0.4);
      }

      // For non-recording state, make heights more subdued
      if (!isRecording) {
        lineHeight = 30; // Fixed height when not recording
      }

      // Position of this bar
      final x = i * (barWidth + spacing) + barWidth / 2;

      // Draw the vertical line
      canvas.drawLine(
        Offset(x, center - lineHeight / 2),
        Offset(x, center + lineHeight / 2),
        paint,
      );
    }

    // Draw horizontal center line
    final centerPaint =
        Paint()
          ..color =
              Colors
                  .transparent // More subtle center line
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
