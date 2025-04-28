import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'dart:async';

class CooldownDialog extends StatefulWidget {
  final int remainingTimeInSeconds;

  const CooldownDialog({super.key, required this.remainingTimeInSeconds});

  @override
  State<CooldownDialog> createState() => _CooldownDialogState();
}

class _CooldownDialogState extends State<CooldownDialog> {
  late int _remainingTimeInSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTimeInSeconds = widget.remainingTimeInSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTimeInSeconds > 0) {
          _remainingTimeInSeconds--;
        } else {
          _timer?.cancel();
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final minutes = _remainingTimeInSeconds ~/ 60;
    final seconds = _remainingTimeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xffD9D9D9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AssetsData.forbbidenIluseration,
              height: Helper.getResponsiveHeight(context, height: 120),
              width: Helper.getResponsiveWidth(context, width: 120),
            ),
            SizedBox(height: Helper.getResponsiveHeight(context, height: 16)),
            Text(
              "Emergency Request Cooldown",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 16),
                color: kPrimary900,
              ),
            ),
            SizedBox(height: Helper.getResponsiveHeight(context, height: 12)),
            Text(
              "You've recently sent an emergency request. For safety reasons, please wait before sending another one.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xff455A64),
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 12),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Helper.getResponsiveHeight(context, height: 16)),
            Text(
              "Time remaining: ${_formatTime()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 12),
                color: kError,
              ),
            ),
            SizedBox(height: Helper.getResponsiveHeight(context, height: 24)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(
                  double.infinity,
                  Helper.getResponsiveHeight(context, height: 45),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("I Understand"),
            ),
          ],
        ),
      ),
    );
  }
}
