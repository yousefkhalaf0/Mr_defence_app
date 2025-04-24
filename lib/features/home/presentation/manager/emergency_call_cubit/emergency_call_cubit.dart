import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:app/features/home/presentation/manager/sos_request_cubit/sos_request_cubit.dart';

// Status enum for better state management
enum EmergencyCallStatus {
  initial,
  loading,
  created,
  accepted,
  expired,
  cancelled,
  error,
}

// Emergency contact model
class EmergencyContact {
  final String id;
  final String name;
  final String image;

  EmergencyContact({String? id, required this.name, required this.image})
    : id = id ?? name.toLowerCase().replaceAll(' ', '_');
}

// State class
class EmergencyCallState extends Equatable {
  final EmergencyCallStatus status;
  final int secondsElapsed;
  final int secondsRemaining;
  final String? errorMessage;
  final SOSRequest? createdRequest;
  final String? acceptedByGuardian;
  final bool isExpired;
  final List<EmergencyContact> emergencyContacts;
  final bool isHandled; // To track if expired requests have been handled
  final String? frontPhotoUrl;
  final String? backPhotoUrl;
  final String? audioUrl;
  const EmergencyCallState({
    this.status = EmergencyCallStatus.initial,
    this.secondsElapsed = 0,
    this.secondsRemaining = 0,
    this.errorMessage,
    this.createdRequest,
    this.acceptedByGuardian,
    this.isExpired = false,
    this.isHandled = false,
    this.emergencyContacts = const [],
    this.frontPhotoUrl,
    this.backPhotoUrl,
    this.audioUrl,
  });

  EmergencyCallState copyWith({
    EmergencyCallStatus? status,
    int? secondsElapsed,
    int? secondsRemaining,
    String? errorMessage,
    SOSRequest? createdRequest,
    String? acceptedByGuardian,
    bool? isExpired,
    bool? isHandled,
    List<EmergencyContact>? emergencyContacts,
    String? frontPhotoUrl,
    String? backPhotoUrl,
    String? audioUrl,
  }) {
    return EmergencyCallState(
      frontPhotoUrl: frontPhotoUrl ?? this.frontPhotoUrl,
      backPhotoUrl: backPhotoUrl ?? this.backPhotoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
      createdRequest: createdRequest ?? this.createdRequest,
      acceptedByGuardian: acceptedByGuardian ?? this.acceptedByGuardian,
      isExpired: isExpired ?? this.isExpired,
      isHandled: isHandled ?? this.isHandled,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    secondsElapsed,
    secondsRemaining,
    errorMessage,
    createdRequest,
    acceptedByGuardian,
    isExpired,
    isHandled,
    emergencyContacts,

    frontPhotoUrl,
    backPhotoUrl,
    audioUrl,
    status,
    secondsElapsed,
    secondsRemaining,
    errorMessage,
    createdRequest,
    acceptedByGuardian,
    isExpired,
    isHandled,
    emergencyContacts,
  ];
}

class EmergencyCallCubit extends Cubit<EmergencyCallState> {
  final RequestCubit requestCubit;
  final Duration timeoutDuration;
  Timer? _timer;
  late final StreamSubscription _requestSubscription;

  // Mock emergency contacts - would come from a repository in a real app
  final List<EmergencyContact> _defaultEmergencyContacts = [
    EmergencyContact(
      name: "Amy Jackson",
      image: "assets/images/contacts/amy.jpg",
    ),
    EmergencyContact(
      name: "Sister",
      image: "assets/images/contacts/sister.jpg",
    ),
    EmergencyContact(name: "Dad", image: "assets/images/contacts/dad.jpg"),
    EmergencyContact(
      name: "Albert",
      image: "assets/images/contacts/albert.jpg",
    ),
  ];

  EmergencyCallCubit({
    required this.requestCubit,
    required this.timeoutDuration,
  }) : super(
         EmergencyCallState(
           secondsRemaining: timeoutDuration.inSeconds,
           emergencyContacts: const [],
         ),
       ) {
    // Listen to request cubit state changes
    _requestSubscription = requestCubit.stream.listen(
      _handleRequestStateChange,
    );
  }

  String get formattedTime {
    int minutes = state.secondsRemaining ~/ 60;
    int seconds = state.secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:00";
  }

  Future<void> initializeEmergencyCall({
    required EmergencyType emergencyType,
    required String frontPhotoPath,
    required String backPhotoPath,
    required String audioPath,
  }) async {
    // Initialize with emergency contacts
    emit(
      state.copyWith(
        emergencyContacts: _defaultEmergencyContacts,
        secondsRemaining: timeoutDuration.inSeconds,
      ),
    );

    // Start timer
    _startTimer();

    // Process emergency request - this calls the method we added to the RequestCubit
    requestCubit.processSosRequest(
      emergencyType,
      frontPhotoPath,
      backPhotoPath,
      audioPath,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newSecondsElapsed = state.secondsElapsed + 1;
      final newSecondsRemaining = state.secondsRemaining - 1;

      emit(
        state.copyWith(
          secondsElapsed: newSecondsElapsed,
          secondsRemaining: newSecondsRemaining,
        ),
      );

      // Check for expiration
      if (newSecondsRemaining <= 0 && !state.isExpired) {
        emit(
          state.copyWith(isExpired: true, status: EmergencyCallStatus.expired),
        );
        _timer?.cancel();
      }
    });
  }

  void _handleRequestStateChange(RequestState requestState) {
    if (requestState is RequestCreated) {
      emit(
        state.copyWith(
          status: EmergencyCallStatus.created,
          createdRequest: requestState.request,
          frontPhotoUrl: requestState.request.frontCameraPhotoUrl,
          backPhotoUrl: requestState.request.backCameraPhotoUrl,
          audioUrl: requestState.request.audioRecordingUrl,
        ),
      );
    } else if (requestState is RequestAccepted) {
      final guardianId = requestState.guardianId;
      String? guardianName = guardianId;

      // Find matching contact name if available
      final contactIndex = state.emergencyContacts.indexWhere(
        (contact) => contact.id == guardianId,
      );

      if (contactIndex != -1) {
        guardianName = state.emergencyContacts[contactIndex].name;
      }

      emit(
        state.copyWith(
          status: EmergencyCallStatus.accepted,
          acceptedByGuardian: guardianName,
          isExpired: true, // Stop expiration timer
        ),
      );

      // Cancel the timer when someone accepts
      _timer?.cancel();
    } else if (requestState is RequestExpired && !state.isExpired) {
      emit(
        state.copyWith(status: EmergencyCallStatus.expired, isExpired: true),
      );
      _timer?.cancel();
    } else if (requestState is RequestError) {
      emit(
        state.copyWith(
          status: EmergencyCallStatus.error,
          errorMessage: requestState.message,
        ),
      );
    } else if (requestState is RequestLoading) {
      emit(state.copyWith(status: EmergencyCallStatus.loading));
    }
  }

  void cancelEmergency() {
    // Stop the timer
    _timer?.cancel();

    // Update state to cancelled
    emit(state.copyWith(status: EmergencyCallStatus.cancelled));

    // In a real app, we would call a method on the request cubit
    // to update the database
    if (state.createdRequest != null) {
      // Implement cancellation logic
      // requestCubit.cancelRequest(state.createdRequest!.id);
    }
  }

  // Mark the expired request as handled to prevent multiple dialogs
  void markAsHandled() {
    emit(state.copyWith(isHandled: true));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _requestSubscription.cancel();
    return super.close();
  }
}
