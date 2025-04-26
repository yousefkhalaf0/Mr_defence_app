import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // This could be your backend API URL or direct Cloudinary API
  final String baseUrl = 'https://your-api-endpoint.com/api';

  // Get emergency media URLs by ID or reference
  Future<Map<String, dynamic>> getEmergencyMedia(String emergencyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emergency/$emergencyId/media'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load emergency media: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting emergency media: $e');
      throw Exception('Failed to get emergency media: $e');
    }
  }

  // Save emergency data including Cloudinary URLs to your backend
  Future<void> saveEmergencyData({
    required String emergencyType,
    required String frontPhotoUrl,
    required String backPhotoUrl,
    required String audioUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'emergencyType': emergencyType,
          'frontPhotoUrl': frontPhotoUrl,
          'backPhotoUrl': backPhotoUrl,
          'audioUrl': audioUrl,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to save emergency data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error saving emergency data: $e');
      throw Exception('Failed to save emergency data: $e');
    }
  }

  // If you don't have a backend, you could use SharedPreferences instead
  // to store the URLs locally on the device
}
