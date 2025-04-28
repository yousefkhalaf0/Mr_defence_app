import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Report extends Equatable {
  final String id;
  final String userId;
  final String emergencyType;
  final String locationName;
  final GeoPoint occuredLocation;
  final DateTime occuredTime;
  final String requestType;
  final String status;
  final List<String> pictures;
  final List<String> videos;
  final List<String> voiceRecords;
  final List<String> receiverGuardians;
  final bool whoHappened;
  final String description;
  final String userName;

  const Report({
    required this.id,
    required this.userId,
    required this.emergencyType,
    required this.locationName,
    required this.occuredLocation,
    required this.occuredTime,
    required this.requestType,
    required this.status,
    required this.pictures,
    required this.videos,
    required this.voiceRecords,
    required this.receiverGuardians,
    required this.whoHappened,
    required this.description,
    this.userName = '',
  });

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    try {
      final timestamp = map['occured_time'];
      final occuredTime =
          timestamp is Timestamp ? timestamp.toDate() : DateTime.now();

      final location = map['occured_location'];
      final occuredLocation =
          location is GeoPoint ? location : const GeoPoint(0, 0);

      // Handle the list types correctly
      List<String> getStringList(dynamic field) {
        if (field == null) return [];
        if (field is List) {
          return field.map((item) => item.toString()).toList();
        }
        if (field is String) return [field];
        return [];
      }

      // Handle description which might be a list or string
      String getDescription(dynamic field) {
        if (field == null) return '';
        if (field is List) {
          return field.isNotEmpty ? field.first.toString() : '';
        }
        return field.toString();
      }

      // Get receiver_guardians as a list
      final guardians = map['receiver_guardians'];
      final List<String> receiverGuardians =
          guardians is List
              ? guardians.map((item) => item.toString()).toList()
              : [];

      return Report(
        id: id,
        userId: map['user_id'] ?? '',
        emergencyType: map['emergency_type'] ?? 'notSelected',
        locationName: map['location_name'] ?? '',
        occuredLocation: occuredLocation,
        occuredTime: occuredTime,
        requestType: map['request_type'] ?? '',
        status: map['status'] ?? 'pending',
        pictures: getStringList(map['pictures']),
        videos: getStringList(map['videos']),
        voiceRecords: getStringList(map['voice_records']),
        receiverGuardians: receiverGuardians,
        whoHappened: map['who_happened'] ?? true,
        description: getDescription(map['description']),
      );
    } catch (e) {
      log('Error parsing report $id: $e');
      rethrow;
    }
  }

  @optionalTypeArgs
  Report copyWith({
    String? id,
    String? userId,
    String? emergencyType,
    String? locationName,
    GeoPoint? occuredLocation,
    DateTime? occuredTime,
    String? requestType,
    String? status,
    List<String>? pictures,
    List<String>? videos,
    List<String>? voiceRecords,
    List<String>? receiverGuardians,
    bool? whoHappened,
    String? description,
    String? userName,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emergencyType: emergencyType ?? this.emergencyType,
      locationName: locationName ?? this.locationName,
      occuredLocation: occuredLocation ?? this.occuredLocation,
      occuredTime: occuredTime ?? this.occuredTime,
      requestType: requestType ?? this.requestType,
      status: status ?? this.status,
      pictures: pictures ?? List<String>.from(this.pictures),
      videos: videos ?? List<String>.from(this.videos),
      voiceRecords: voiceRecords ?? List<String>.from(this.voiceRecords),
      receiverGuardians:
          receiverGuardians ?? List<String>.from(this.receiverGuardians),
      whoHappened: whoHappened ?? this.whoHappened,
      description: description ?? this.description,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object> get props => [
    id,
    userId,
    emergencyType,
    locationName,
    occuredLocation,
    occuredTime,
    requestType,
    status,
    pictures,
    videos,
    voiceRecords,
    receiverGuardians,
    whoHappened,
    description,
    userName,
  ];
}
