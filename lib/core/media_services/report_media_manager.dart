import 'package:app/core/media_services/cloudinary_service_for_uploading_media.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class ReportMediaManager {
  final CloudinaryStorageService _cloudinaryService =
      CloudinaryStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a specific report with all media
  Future<Map<String, dynamic>> getReportWithMedia(String reportId) async {
    try {
      // Get report document
      final reportDoc =
          await _firestore.collection('reports').doc(reportId).get();

      if (!reportDoc.exists) {
        throw Exception('Report not found');
      }

      // Get all media URLs
      final mediaUrls = await _cloudinaryService.getReportMedia(reportId);

      // Combine document data with media URLs
      final reportData = reportDoc.data() ?? {};

      return {...reportData, 'mediaUrls': mediaUrls};
    } catch (e) {
      debugPrint('Error fetching report: $e');
      throw Exception('Failed to fetch report: $e');
    }
  }

  // Get all reports for a specific user
  Future<List<Map<String, dynamic>>> getUserReports(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('reports')
              .where('user_id', isEqualTo: userId)
              .orderBy('occured_time', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error fetching user reports: $e');
      throw Exception('Failed to fetch user reports: $e');
    }
  }

  // Build a widget to display report images
  Widget buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const Center(child: Text('No images available'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, imageUrls[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
            ),
          ),
        );
      },
    );
  }

  // Show full screen image
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  // Build a widget to play audio files
  Widget buildAudioPlayer(String audioUrl) {
    if (audioUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return AudioPlayerWidget(audioUrl: audioUrl);
  }

  // Build a widget to play video files
  Widget buildVideoPlayer(String videoUrl) {
    if (videoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return VideoPlayerWidget(videoUrl: videoUrl);
  }
}

// Audio Player Widget
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);

      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 40,
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Audio Recording',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_formatDuration(_position)),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0,
                  max: _duration.inSeconds.toDouble() + 1.0,
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(_formatDuration(_duration)),
            ],
          ),
        ],
      ),
    );
  }
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
