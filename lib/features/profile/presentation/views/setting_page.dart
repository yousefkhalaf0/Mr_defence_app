import 'dart:developer';
import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSettingItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        log("Tapped on $title");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D7D7D),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF7D7D7D),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).pop();
                    },
                    child: Image.asset(
                      'assets/profile_assets/images/BackIcon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Settings List
            _buildSettingItem(context, "Customize Alert Actions"),
            _buildSettingItem(context, "Privacy Settings"),
            _buildSettingItem(context, "Location Settings"),
            _buildSettingItem(context, "Audio / Video Settings"),
            _buildSettingItem(context, "Accessibility Options"),
            _buildSettingItem(context, "Incident History"),

            const SizedBox(height: 20),

            // Help & Guide Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Help & Guide",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7D7D7D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "- How to use Mr. Defence?",
                      style: TextStyle(color: Color(0xFF4E4E4E)),
                    ),
                    Text(
                      "- What to do during an emergency?",
                      style: TextStyle(color: Color(0xFF4E4E4E)),
                    ),
                    Text(
                      "- Legal rights and support resources.",
                      style: TextStyle(color: Color(0xFF4E4E4E)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Footer
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "All Rights reserved @Mr. Defence - 2025",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E4E4E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
