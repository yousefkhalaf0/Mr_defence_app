import 'dart:io';
import 'package:app/core/utils/constants.dart';
import 'package:app/features/alert_request/presentation/views/widget/video_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/utils/helper.dart';

class MediaPreviewPage extends StatefulWidget {
  final List<File> photos;
  final List<File> videos;

  const MediaPreviewPage({
    super.key,
    required this.photos,
    required this.videos,
  });

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  Set<int> selectedPhotoIndices = {};
  Set<int> selectedVideoIndices = {};
  bool isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        titleSpacing: 0,
        title: Text(
          isSelectionMode ? 'Select Items' : 'Media Preview',
          style: TextStyle(
            color: isSelectionMode ? kTextRedColor : Colors.black87,
            fontSize: Helper.getResponsiveWidth(context, width: 20),
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 8),
          constraints: const BoxConstraints(),
          iconSize: Helper.getResponsiveWidth(
            context,
            width: Helper.getResponsiveWidth(context, width: 25),
          ),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (isSelectionMode) {
              setState(() {
                isSelectionMode = false;
                selectedPhotoIndices.clear();
                selectedVideoIndices.clear();
              });
            } else {
              GoRouter.of(context).pop();
            }
          },
        ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteSelectedMedia();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.photos.isNotEmpty) ...[
                Text(
                  'Live Footage/Picture',
                  style: TextStyle(
                    fontSize: Helper.getResponsiveFontSize(
                      context,
                      fontSize: 14,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Helper.getResponsiveWidth(context, width: 12)),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          isSelectionMode = true;
                          _togglePhotoSelection(index);
                        });
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          setState(() {
                            _togglePhotoSelection(index);
                          });
                        } else {
                          _showFullScreenImage(context, widget.photos[index]);
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(widget.photos[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (selectedPhotoIndices.contains(index))
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              if (widget.videos.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Live stream',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...widget.videos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final video = entry.value;
                  return Stack(
                    children: [
                      VideoPreviewTile(
                        videoFile: video,
                        isSelected: selectedVideoIndices.contains(index),
                        onTap: () {
                          if (isSelectionMode) {
                            setState(() {
                              _toggleVideoSelection(index);
                            });
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            isSelectionMode = true;
                            _toggleVideoSelection(index);
                          });
                        },
                      ),
                      if (selectedVideoIndices.contains(index))
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _togglePhotoSelection(int index) {
    if (selectedPhotoIndices.contains(index)) {
      selectedPhotoIndices.remove(index);
    } else {
      selectedPhotoIndices.add(index);
    }
    if (selectedPhotoIndices.isEmpty && selectedVideoIndices.isEmpty) {
      setState(() {
        isSelectionMode = false;
      });
    }
  }

  void _toggleVideoSelection(int index) {
    if (selectedVideoIndices.contains(index)) {
      selectedVideoIndices.remove(index);
    } else {
      selectedVideoIndices.add(index);
    }
    if (selectedPhotoIndices.isEmpty && selectedVideoIndices.isEmpty) {
      setState(() {
        isSelectionMode = false;
      });
    }
  }

  void _deleteSelectedMedia() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Media'),
            content: const Text(
              'Are you sure you want to delete the selected media?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performDeletion();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _performDeletion() {
    // Create new lists without the deleted items
    final newPhotos = List<File>.from(widget.photos);
    final newVideos = List<File>.from(widget.videos);

    // Remove selected items in reverse order to avoid index issues
    final sortedPhotoIndices =
        selectedPhotoIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedPhotoIndices) {
      newPhotos.removeAt(index);
    }

    final sortedVideoIndices =
        selectedVideoIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedVideoIndices) {
      newVideos.removeAt(index);
    }

    // Update the parent widget's state
    Navigator.pop(context, {'photos': newPhotos, 'videos': newVideos});
  }

  void _showFullScreenImage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(imageFile),
                ),
              ),
            ),
      ),
    );
  }
}
