// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AutoRecordPage extends StatefulWidget {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;

  const AutoRecordPage({
    super.key,
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
  });

  @override
  State<AutoRecordPage> createState() => _AutoRecordPageState();
}

class _AutoRecordPageState extends State<AutoRecordPage>
    with WidgetsBindingObserver {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _recordingDuration = 0;
  String _audioPath = '';
  Timer? _timer;
  final int _totalDuration = 60; // Total recording duration in seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initRecorder();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // App is going to background, we should ensure recording is handled properly
      if (_isRecording) {
        _pauseOrResumeRecording();
      }
    }
  }

  Future<void> _initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _setError('Microphone permission denied');
        return;
      }

      await _recorder.openRecorder();

      // Check if the recorder is properly opened
      setState(() {
        _isInitialized = true;
      });

      // Generate a file path for recording
      final tempDir = await getTemporaryDirectory();
      _audioPath =
          '${tempDir.path}/emergency_audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Start recording after a brief delay to ensure UI is rendered
      Future.delayed(Duration(milliseconds: 500), () {
        _startRecording();
      });
    } catch (e) {
      _setError('Error initializing recorder: $e');
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_isInitialized) {
      _setError('Recorder not initialized');
      return;
    }

    try {
      // Set recording parameters
      await _recorder.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start a timer for recording duration
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration++;
          });

          // After specified duration, finish recording and proceed
          if (_recordingDuration >= _totalDuration) {
            _finishRecording();
          }
        }
      });
    } catch (e) {
      _setError('Error starting recording: $e');
    }
  }

  Future<void> _pauseOrResumeRecording() async {
    if (!_isRecording) return;

    try {
      if (_recorder.isPaused) {
        await _recorder.resumeRecorder();
      } else {
        await _recorder.pauseRecorder();
      }

      if (mounted) {
        setState(() {
          // Update UI
        });
      }
    } catch (e) {
      // Handle error but don't stop the recording process
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
    }
  }

  Future<void> _finishRecording() async {
    if (!_isRecording) return;

    _timer?.cancel();
    _timer = null;

    try {
      final String? path = await _recorder.stopRecorder();

      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioPath = path;
        }
      });

      // Verify the file exists and has content
      final file = File(_audioPath);
      if (await file.exists() && await file.length() > 0) {
        // Navigate to the calling emergency page
        if (mounted) {
          context.pushReplacement(
            '/emergency-calling',
            extra: {
              'emergencyType': widget.emergencyType,
              'frontPhotoPath': widget.frontPhotoPath,
              'backPhotoPath': widget.backPhotoPath,
              'audioPath': _audioPath,
            },
          );
        }
      } else {
        _setError('Recording failed: Empty or missing audio file');
      }
    } catch (e) {
      _setError('Error finishing recording: $e');
    }
  }

  void _skipRecording() {
    // Skip recording and proceed with empty audio path
    _timer?.cancel();
    _timer = null;

    if (_isRecording) {
      _recorder
          .stopRecorder()
          .then((_) {
            if (mounted) {
              context.pushReplacement(
                '/emergency-calling',
                extra: {
                  'emergencyType': widget.emergencyType,
                  'frontPhotoPath': widget.frontPhotoPath,
                  'backPhotoPath': widget.backPhotoPath,
                  'audioPath': '', // Empty path indicates skipped recording
                },
              );
            }
          })
          .catchError((e) {
            // Even if stopping fails, still proceed
            if (mounted) {
              context.pushReplacement(
                '/emergency-calling',
                extra: {
                  'emergencyType': widget.emergencyType,
                  'frontPhotoPath': widget.frontPhotoPath,
                  'backPhotoPath': widget.backPhotoPath,
                  'audioPath': '',
                },
              );
            }
          });
    } else {
      if (mounted) {
        context.pushReplacement(
          '/emergency-calling',
          extra: {
            'emergencyType': widget.emergencyType,
            'frontPhotoPath': widget.frontPhotoPath,
            'backPhotoPath': widget.backPhotoPath,
            'audioPath': '',
          },
        );
      }
    }
  }

  String _formatDuration() {
    final minutes = (_recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    return _recordingDuration / _totalDuration;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before allowing back navigation
        final shouldPop = await _showExitConfirmationDialog();
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
              final shouldExit = await _showExitConfirmationDialog();
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
              onPressed: _skipRecording,
              child: Text('Skip', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildErrorScreen() {
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
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 24),
              Text(
                'Audio Recording Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                  });
                  _initRecorder();
                },
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _skipRecording,
                child: Text('Continue Without Audio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isRecording ? Colors.red : Colors.grey,
              ),
              minHeight: 6,
            ),
          ),
          SizedBox(height: 8),

          // Countdown text
          Text(
            'Recording: ${_formatDuration()} / ${_totalDuration ~/ 60}:${(_totalDuration % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),

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
                  'Audio recording will complete in ${_totalDuration - _recordingDuration} seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Please stay on this page to avoid cancellation',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          // Audio visualization
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _isInitialized
                    ? _buildAudioWaveform()
                    : Center(child: CircularProgressIndicator()),
          ),

          SizedBox(height: 40),

          // Recording button and status
          Column(
            children: [
              GestureDetector(
                onTap: _isInitialized ? _pauseOrResumeRecording : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        _isRecording
                            ? (_recorder.isPaused
                                ? Colors.grey[400]
                                : Colors.red[400])
                            : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isRecording
                          ? (_recorder.isPaused ? Icons.mic_off : Icons.mic)
                          : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                _formatDuration(),
                style: TextStyle(
                  color: _isRecording ? Colors.red[400] : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _isRecording
                    ? (_recorder.isPaused
                        ? 'Recording paused'
                        : 'Recording in progress...')
                    : 'Initializing...',
                style: TextStyle(
                  color:
                      _isRecording
                          ? (_recorder.isPaused ? Colors.grey[700] : Colors.red)
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

  Widget _buildAudioWaveform() {
    if (!_isRecording) {
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
        progress: _recordingDuration,
        isRecording: _isRecording && !_recorder.isPaused,
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Recording?'),
          content: Text(
            'If you leave now, your recording will be lost. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
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
