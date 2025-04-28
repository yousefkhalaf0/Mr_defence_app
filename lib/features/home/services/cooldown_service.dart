// emergency_request_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyRequestService {
  static const int _cooldownPeriodInSeconds = 300; // 5 minutes cooldown
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton instance
  static final EmergencyRequestService _instance =
      EmergencyRequestService._internal();

  factory EmergencyRequestService() {
    return _instance;
  }

  EmergencyRequestService._internal();

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Check if a user can make a new request by querying Firestore
  Future<bool> canMakeRequest() async {
    if (_currentUserId == null) {
      // If user is not logged in, fall back to local device check
      return _checkLocalCooldown();
    }

    try {
      // Query recent requests from this user
      final querySnapshot =
          await _firestore
              .collection('reports')
              .where('user_id', isEqualTo: _currentUserId)
              .orderBy('occured_time', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // No previous requests found
      }

      // Get the most recent request timestamp
      final lastRequestDoc = querySnapshot.docs.first;
      final Timestamp lastRequestTimestamp =
          lastRequestDoc['occured_time'] is Timestamp
              ? lastRequestDoc['occured_time']
              : Timestamp.fromDate(
                DateTime.parse(lastRequestDoc['occured_time'].toString()),
              );

      // Calculate time elapsed
      final lastRequestTime = lastRequestTimestamp.toDate();
      final currentTime = DateTime.now();
      final timeElapsedInSeconds =
          currentTime.difference(lastRequestTime).inSeconds;

      return timeElapsedInSeconds >= _cooldownPeriodInSeconds;
    } catch (e) {
      print('Error checking request cooldown: $e');
      // Fall back to local device check if Firestore query fails
      return _checkLocalCooldown();
    }
  }

  // Fallback to check local device storage if Firestore is unavailable
  Future<bool> _checkLocalCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequestTime = prefs.getInt('last_emergency_request_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final timeElapsedInSeconds = (currentTime - lastRequestTime) ~/ 1000;
    return timeElapsedInSeconds >= _cooldownPeriodInSeconds;
  }

  // Record that a request was made (both in Firestore and locally)
  Future<void> recordRequest() async {
    // Update local device storage as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_emergency_request_time',
      DateTime.now().millisecondsSinceEpoch,
    );

    // Note: The actual Firestore document will be created when the emergency
    // request is submitted, so we don't need to create a record here
  }

  // Get the remaining cooldown time in seconds
  Future<int> getRemainingCooldownTime() async {
    if (_currentUserId == null) {
      return _getLocalRemainingCooldownTime();
    }

    try {
      // Query most recent request from this user
      final querySnapshot =
          await _firestore
              .collection('reports')
              .where('user_id', isEqualTo: _currentUserId)
              .orderBy('occured_time', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return 0; // No previous requests found
      }

      // Get the most recent request timestamp
      final lastRequestDoc = querySnapshot.docs.first;
      final Timestamp lastRequestTimestamp =
          lastRequestDoc['occured_time'] is Timestamp
              ? lastRequestDoc['occured_time']
              : Timestamp.fromDate(
                DateTime.parse(lastRequestDoc['occured_time'].toString()),
              );

      // Calculate remaining time
      final lastRequestTime = lastRequestTimestamp.toDate();
      final currentTime = DateTime.now();
      final elapsedSeconds = currentTime.difference(lastRequestTime).inSeconds;
      final remainingSeconds = _cooldownPeriodInSeconds - elapsedSeconds;

      return remainingSeconds > 0 ? remainingSeconds : 0;
    } catch (e) {
      print('Error getting remaining cooldown time: $e');
      // Fall back to local device check
      return _getLocalRemainingCooldownTime();
    }
  }

  // Get remaining cooldown from local storage
  Future<int> _getLocalRemainingCooldownTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequestTime = prefs.getInt('last_emergency_request_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final timeElapsedInSeconds = (currentTime - lastRequestTime) ~/ 1000;
    final remainingTime = _cooldownPeriodInSeconds - timeElapsedInSeconds;

    return remainingTime > 0 ? remainingTime : 0;
  }

  // Format the remaining time as mm:ss
  String formatRemainingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
