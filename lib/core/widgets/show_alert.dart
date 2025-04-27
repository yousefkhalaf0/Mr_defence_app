import 'package:app/core/widgets/animated_popup_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showPopUpAlert({
  required BuildContext context,
  required String message,
  required IconData icon,
  required Color color,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder:
        (context) => Stack(
          children: [
            GestureDetector(
              onTap: () {
                GoRouter.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
            ),
            AnimatedPopupMessage(
              icon: icon,
              alertColor: color,
              message: message,
              onDismissed: () {
                GoRouter.of(context).pop();
              },
            ),
          ],
        ),
  );
}
