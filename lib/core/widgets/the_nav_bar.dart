import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 243,
        height: 60,
        decoration: BoxDecoration(
          color: kPrimary900,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, color: kNeutral500),
            Icon(Icons.sos, color: kNeutral500),
            Icon(Icons.settings, color: kNeutral500),
          ],
        ),
      ),
    );
  }
}
