import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:go_router/go_router.dart';

class EmergencyCallingPage extends StatefulWidget {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;
  final String audioPath;

  const EmergencyCallingPage({
    Key? key,
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
    required this.audioPath,
  }) : super(key: key);

  @override
  State<EmergencyCallingPage> createState() => _EmergencyCallingPageState();
}

class _EmergencyCallingPageState extends State<EmergencyCallingPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  bool _isAudioLoaded = false;
  double _audioProgress = 0.0;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isCallInProgress = false;
  bool _showMediaPreview = true;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      if (widget.audioPath.isNotEmpty) {
        await _audioPlayer.setFilePath(widget.audioPath);
        _audioDuration = _audioPlayer.duration ?? Duration.zero;

        _audioPlayer.positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _audioPosition = position;
              _audioProgress =
                  position.inMilliseconds /
                  (_audioDuration.inMilliseconds == 0
                      ? 1
                      : _audioDuration.inMilliseconds);
            });
          }
        });

        _audioPlayer.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isAudioPlaying = state.playing;
              if (state.processingState == ProcessingState.completed) {
                _audioProgress = 0.0;
                _audioPosition = Duration.zero;
              }
            });
          }
        });

        setState(() {
          _isAudioLoaded = true;
        });
      }
    } catch (e) {
      print('Error initializing audio player: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load audio: $e')));
    }
  }

  void _toggleAudioPlayback() async {
    if (_isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    }
  }

  Future<void> _startEmergencyCall() async {
    setState(() {
      _isCallInProgress = true;
      _showMediaPreview = false;
    });

    // In a real app, this would initiate the emergency call and send the media files
    // For demonstration, we'll just simulate a delay
    await Future.delayed(const Duration(seconds: 3));

    // After call is connected, you might navigate to a different screen or show a success message
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Emergency services notified')));

      // Return to home page after emergency call is handled
      context.pushReplacement('/homeView');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
            _isCallInProgress
                ? _buildCallingScreen()
                : _buildMediaPreviewScreen(),
      ),
    );
  }

  Widget _buildMediaPreviewScreen() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency Data Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Emergency type indicator
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                widget.emergencyType.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Photo previews
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Front camera image preview
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.frontPhotoPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Front Photo',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Back camera image preview
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.backPhotoPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Back Photo', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Audio playback controls
        if (widget.audioPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: Colors.white70),
                      SizedBox(width: 12),
                      Text(
                        'Audio Recording',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Play button and progress bar
                  Row(
                    children: [
                      // Play/Pause button
                      IconButton(
                        icon: Icon(
                          _isAudioPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: _isAudioLoaded ? _toggleAudioPlayback : null,
                      ),
                      SizedBox(width: 12),
                      // Progress bar and duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _audioProgress,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_audioPosition),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_audioDuration),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        Spacer(),

        // Emergency call action button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.phone_enabled),
            label: Text('CONTACT EMERGENCY SERVICES'),
            onPressed: _startEmergencyCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              minimumSize: Size(double.infinity, 56),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing call icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: Center(
              child: Icon(Icons.phone_in_talk, color: Colors.red, size: 60),
            ),
          ),
          SizedBox(height: 32),
          // Status text
          Text(
            'Contacting Emergency Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Sending photos and audio...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 32),
          // Progress indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ],
      ),
    );
  }
}
