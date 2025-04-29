import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadProgressPage extends StatefulWidget {
  final double progress;
  final String message;
  final bool isComplete;

  const UploadProgressPage({
    Key? key,
    required this.progress,
    required this.message,
    this.isComplete = false,
  }) : super(key: key);

  @override
  State<UploadProgressPage> createState() => _UploadProgressPageState();
}

class _UploadProgressPageState extends State<UploadProgressPage> {
  bool _navigating = false;

  @override
  void didUpdateWidget(UploadProgressPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger navigation only when isComplete changes from false to true
    if (!oldWidget.isComplete && widget.isComplete && !_navigating) {
      _handleCompletion();
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if already complete on initial load
    if (widget.isComplete) {
      _handleCompletion();
    }
  }

  void _handleCompletion() {
    setState(() {
      _navigating = true;
    });

    // Add delay before navigation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show different icons based on state
                Icon(
                  widget.isComplete ? Icons.check_circle : Icons.cloud_upload,
                  size: 80,
                  color:
                      widget.isComplete
                          ? Colors.green
                          : const Color(0xFFFF5A5F),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  widget.isComplete
                      ? 'Report Submitted!'
                      : 'Submitting Emergency Report',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Progress message
                Text(
                  widget.message,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Progress indicator
                widget.isComplete
                    ? const SizedBox() // No progress bar when complete
                    : Column(
                      children: [
                        LinearProgressIndicator(
                          value: widget.progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF5A5F),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(widget.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 48),
                if (widget.isComplete) ...[
                  ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Button for manual navigation
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
