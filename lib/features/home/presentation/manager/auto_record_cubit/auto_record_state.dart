// auto_record_state.dart
part of 'auto_record_cubit.dart';

class AutoRecordState extends Equatable {
  final bool isRecording;
  final bool isInitialized;
  final bool hasError;
  final String errorMessage;
  final int recordingDuration;
  final String audioPath;
  final bool isRecordingComplete;

  const AutoRecordState({
    required this.isRecording,
    required this.isInitialized,
    required this.hasError,
    required this.errorMessage,
    required this.recordingDuration,
    required this.audioPath,
    required this.isRecordingComplete,
  });

  AutoRecordState copyWith({
    bool? isRecording,
    bool? isInitialized,
    bool? hasError,
    String? errorMessage,
    int? recordingDuration,
    String? audioPath,
    bool? isRecordingComplete,
  }) {
    return AutoRecordState(
      isRecording: isRecording ?? this.isRecording,
      isInitialized: isInitialized ?? this.isInitialized,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      audioPath: audioPath ?? this.audioPath,
      isRecordingComplete: isRecordingComplete ?? this.isRecordingComplete,
    );
  }

  @override
  List<Object?> get props => [
    isRecording,
    isInitialized,
    hasError,
    errorMessage,
    recordingDuration,
    audioPath,
    isRecordingComplete,
  ];
}
