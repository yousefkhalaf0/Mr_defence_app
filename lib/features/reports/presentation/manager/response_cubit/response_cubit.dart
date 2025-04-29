import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'response_state.dart';

class EmergencyRequestCubit extends Cubit<EmergencyRequestState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmergencyRequestCubit() : super(EmergencyRequestInitial());

  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      emit(EmergencyRequestLoading());

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        emit(EmergencyRequestFailed('User not found'));
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      emit(EmergencyRequestUserLoaded(userData));
      return userData;
    } catch (e) {
      log('Error fetching user data: $e');
      emit(EmergencyRequestFailed('Failed to load user data: $e'));
      return null;
    }
  }

  Future<void> acceptEmergencyRequest(
    String reportId,
    String guardianId,
  ) async {
    try {
      emit(EmergencyRequestProcessing());

      final reportRef = _firestore.collection('reports').doc(reportId);
      final reportDoc = await reportRef.get();

      if (!reportDoc.exists) {
        emit(EmergencyRequestFailed('Report not found'));
        return;
      }

      final data = reportDoc.data() as Map<String, dynamic>;
      final List<dynamic> guardians = List.from(
        data['receiver_guardians'] ?? [],
      );

      // Add guardian if not already in the list
      if (!guardians.contains(guardianId)) {
        guardians.add(guardianId);
        await reportRef.update({
          'receiver_guardians': guardians,
          'status': 'open', // Update status to open when a guardian accepts
        });
      }

      // Update the status if there are guardians and it's not already closed
      if (guardians.isNotEmpty && data['status'] != 'closed') {
        await reportRef.update({'status': 'open'});
      }

      // Notify the report owner that a guardian has accepted
      await _notifyUser(
        data['user_id'],
        'A guardian has accepted your emergency request',
      );

      emit(EmergencyRequestSuccess('Emergency request accepted successfully'));
    } catch (e) {
      log('Error accepting emergency request: $e');
      emit(EmergencyRequestFailed('Failed to accept emergency request: $e'));
    }
  }

  Future<void> declineEmergencyRequest(
    String reportId,
    String guardianId,
  ) async {
    try {
      emit(EmergencyRequestProcessing());

      final reportRef = _firestore.collection('reports').doc(reportId);
      final reportDoc = await reportRef.get();

      if (!reportDoc.exists) {
        emit(EmergencyRequestFailed('Report not found'));
        return;
      }

      final data = reportDoc.data() as Map<String, dynamic>;
      final List<dynamic> guardians = List.from(
        data['receiver_guardians'] ?? [],
      );

      // Remove guardian if in the list
      if (guardians.contains(guardianId)) {
        guardians.remove(guardianId);
        await reportRef.update({'receiver_guardians': guardians});
      }

      // Update status to pending if no guardians are left and it's not closed
      if (guardians.isEmpty && data['status'] != 'closed') {
        await reportRef.update({'status': 'pending'});
      }

      emit(EmergencyRequestSuccess('Emergency request declined successfully'));
    } catch (e) {
      log('Error declining emergency request: $e');
      emit(EmergencyRequestFailed('Failed to decline emergency request: $e'));
    }
  }

  Future<void> closeEmergencyRequest(String reportId) async {
    try {
      emit(EmergencyRequestProcessing());

      final reportRef = _firestore.collection('reports').doc(reportId);
      await reportRef.update({'status': 'closed'});

      emit(EmergencyRequestSuccess('Emergency request closed successfully'));
    } catch (e) {
      log('Error closing emergency request: $e');
      emit(EmergencyRequestFailed('Failed to close emergency request: $e'));
    }
  }

  Future<void> _notifyUser(String userId, String message) async {
    try {
      // This is a placeholder for sending a notification to the user
      // You would typically integrate with FCM (Firebase Cloud Messaging) here

      // For now, we'll just add a notification entry to Firestore
      await _firestore.collection('notifications').add({
        'user_id': userId,
        'message': message,
        'read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error sending notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmergencyResponders(
    String reportId,
  ) async {
    try {
      final reportDoc =
          await _firestore.collection('reports').doc(reportId).get();

      if (!reportDoc.exists) {
        return [];
      }

      final data = reportDoc.data() as Map<String, dynamic>;
      final List<dynamic> guardians = List.from(
        data['receiver_guardians'] ?? [],
      );

      if (guardians.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> responders = [];

      for (String guardianId in guardians.cast<String>()) {
        final userDoc =
            await _firestore.collection('users').doc(guardianId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          responders.add({
            'id': guardianId,
            'name':
                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                    .trim(),
            'phoneNumber': userData['phoneNumber'] ?? '',
            'profilePicture': userData['profilePicture'],
          });
        }
      }

      return responders;
    } catch (e) {
      log('Error fetching emergency responders: $e');
      return [];
    }
  }

  Future<void> updateEmergencyLocation(
    String reportId,
    GeoPoint location,
    String locationName,
  ) async {
    try {
      emit(EmergencyRequestProcessing());

      await _firestore.collection('reports').doc(reportId).update({
        'occured_location': location,
        'location_name': locationName,
      });

      emit(EmergencyRequestSuccess('Location updated successfully'));
    } catch (e) {
      log('Error updating emergency location: $e');
      emit(EmergencyRequestFailed('Failed to update location: $e'));
    }
  }

  Future<void> addMediaToEmergency(
    String reportId,
    List<String> newImages,
    List<String> newVideos,
  ) async {
    try {
      emit(EmergencyRequestProcessing());

      final reportDoc =
          await _firestore.collection('reports').doc(reportId).get();

      if (!reportDoc.exists) {
        emit(EmergencyRequestFailed('Report not found'));
        return;
      }

      final data = reportDoc.data() as Map<String, dynamic>;
      final List<dynamic> currentImages = List.from(data['pictures'] ?? []);
      final List<dynamic> currentVideos = List.from(data['videos'] ?? []);

      // Add new media
      currentImages.addAll(newImages);
      currentVideos.addAll(newVideos);

      await _firestore.collection('reports').doc(reportId).update({
        'pictures': currentImages,
        'videos': currentVideos,
      });

      emit(EmergencyRequestSuccess('Media added successfully'));
    } catch (e) {
      log('Error adding media to emergency: $e');
      emit(EmergencyRequestFailed('Failed to add media: $e'));
    }
  }

  Future<void> updateEmergencyDescription(
    String reportId,
    String description,
  ) async {
    try {
      emit(EmergencyRequestProcessing());

      await _firestore.collection('reports').doc(reportId).update({
        'description': description,
      });

      emit(EmergencyRequestSuccess('Description updated successfully'));
    } catch (e) {
      log('Error updating emergency description: $e');
      emit(EmergencyRequestFailed('Failed to update description: $e'));
    }
  }
}
