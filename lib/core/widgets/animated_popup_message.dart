import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';

class AnimatedPopupMessage extends StatefulWidget {
  const AnimatedPopupMessage({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.onDismissed,
    required this.alertColor,
    required this.icon,
  });
  final String message;
  final Color alertColor;
  final Duration duration;
  final VoidCallback? onDismissed;
  final IconData icon;

  @override
  State<AnimatedPopupMessage> createState() => _AnimatedPopupMessageState();
}

class _AnimatedPopupMessageState extends State<AnimatedPopupMessage> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _show = true);
      Future.delayed(widget.duration, () {
        if (mounted) {
          setState(() => _show = false);
          widget.onDismissed?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _show ? 0 : -100, 0),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.alertColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: kNeutral500),
            const SizedBox(width: 8),
            Text(
              widget.message,
              style: Styles.textStyle14(context).copyWith(color: kNeutral500),
            ),
          ],
        ),
      ),
    );
  }
}
