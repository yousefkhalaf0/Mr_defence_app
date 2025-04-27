import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:app/core/utils/constants.dart';
import 'package:go_router/go_router.dart';

class UploadProgressPage extends StatelessWidget {
  final double progress;
  final String message;
  final bool isComplete;
  final VoidCallback? onComplete;

  const UploadProgressPage({
    Key? key,
    required this.progress,
    required this.message,
    this.isComplete = false,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If complete, show success and auto-navigate after delay
    if (isComplete) {
      Future.delayed(const Duration(seconds: 2), () {
        if (onComplete != null) {
          onComplete!();
        }
      });
    }

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
                  isComplete ? Icons.check_circle : Icons.cloud_upload,
                  size: 80,
                  color: isComplete ? Colors.green : const Color(0xFFFF5A5F),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  isComplete
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
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Progress indicator
                isComplete
                    ? const SizedBox() // No progress bar when complete
                    : Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF5A5F),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 48),

                // Button for complete state
                if (isComplete)
                  ElevatedButton(
                    onPressed: () => context.go(AppRouter.kHomeView),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
