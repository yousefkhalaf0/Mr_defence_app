import 'dart:developer';
import 'package:app/features/reports/data/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's UID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get sent reports - reports created by the current user
  Stream<List<Report>> getSentReports() {
    if (_currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('reports')
        .where('user_id', isEqualTo: _currentUserId)
        .orderBy('occured_time', descending: true)
        .snapshots()
        .asyncMap((snapshot) => _processReports(snapshot));
  }

  // Get received reports - reports where the current user is in receiver_guardians
  Stream<List<Report>> getReceivedReports() {
    if (_currentUserId == null) return Stream.value([]);

    // This query gets reports where the current user is in the receiver_guardians array
    return _firestore
        .collection('reports')
        .where('receiver_guardians', arrayContains: _currentUserId)
        .orderBy('occured_time', descending: true)
        .snapshots()
        .asyncMap((snapshot) => _processReports(snapshot));
  }

  // Process reports and fetch user information
  Future<List<Report>> _processReports(QuerySnapshot snapshot) async {
    final reports = <Report>[];

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final report = Report.fromMap(data, doc.id);

        // Fetch user name if it exists
        final reportWithUserName = await _fetchUserName(report);
        reports.add(reportWithUserName);
      } catch (e) {
        log('Error processing report ${doc.id}: $e');
        // Continue to next report
      }
    }

    return reports;
  }

  // Fetch user name for the report
  Future<Report> _fetchUserName(Report report) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(report.userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        final fullName = '$firstName $lastName'.trim();

        return report.copyWith(
          userName: fullName.isNotEmpty ? fullName : 'Unknown User',
        );
      }
    } catch (e) {
      log('Error fetching user details for ${report.userId}: $e');
    }

    return report;
  }

  // Clear reports functionality
  Future<void> clearReportsByDate(String dateGroup, bool isReceived) async {
    if (_currentUserId == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? startDate;
    DateTime? endDate;

    // Determine date range based on dateGroup
    if (dateGroup == 'Today') {
      startDate = today;
      endDate = today.add(const Duration(days: 1));
    } else if (dateGroup == 'Yesterday') {
      startDate = yesterday;
      endDate = today;
    } else {
      // For other date formats, we'd need more complex logic
      // For now, this is a simple implementation
      return;
    }

    // Get reference to the collection
    final reportsRef = _firestore.collection('reports');

    // Create appropriate query based on whether we're clearing sent or received reports
    Query query;
    if (isReceived) {
      query = reportsRef.where(
        'receiver_guardians',
        arrayContains: _currentUserId,
      );
    } else {
      query = reportsRef.where('user_id', isEqualTo: _currentUserId);
    }

    // Add date filter
    query = query
        .where(
          'occured_time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('occured_time', isLessThan: Timestamp.fromDate(endDate));

    // Execute query and delete documents (in a real app, you might want to batch this)
    final querySnapshot = await query.get();
    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
