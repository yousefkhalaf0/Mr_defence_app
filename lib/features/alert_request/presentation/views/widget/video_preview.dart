import 'dart:io';

import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewTile extends StatefulWidget {
  final File videoFile;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const VideoPreviewTile({
    super.key,
    required this.videoFile,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<VideoPreviewTile> createState() => _VideoPreviewTileState();
}

class _VideoPreviewTileState extends State<VideoPreviewTile> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        height: Helper.getResponsiveHeight(context, height: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _isInitialized
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      if (!widget.isSelected)
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                        ),
                    ],
                  ),
                )
                : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
      ),
    );
  }
}
