import 'package:flutter/material.dart';

class UploadProgressOverlay extends StatelessWidget {
  final String message;
  final double progress;

  const UploadProgressOverlay({
    super.key,
    this.message = 'Submitting emergency request...',
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(35, 0, 0, 0),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated upload icon
            const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 4,
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.red,
            ),

            const SizedBox(height: 8),

            // Progress percentage
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
