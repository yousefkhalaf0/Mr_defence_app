// auto_record_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'auto_record_state.dart';

class AutoRecordCubit extends Cubit<AutoRecordState> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Timer? _timer;
  final int _totalDuration = 60; // Total recording duration in seconds

  AutoRecordCubit()
    : super(
        const AutoRecordState(
          isRecording: false,
          isInitialized: false,
          hasError: false,
          errorMessage: '',
          recordingDuration: 0,
          audioPath: '',
          isRecordingComplete: false,
        ),
      );

  Future<void> initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setError('Microphone permission denied');
        return;
      }

      await _recorder.openRecorder();

      // Generate a file path for recording
      final tempDir = await getTemporaryDirectory();
      final audioPath =
          '${tempDir.path}/emergency_audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      emit(state.copyWith(isInitialized: true, audioPath: audioPath));

      // Start recording after a brief delay to ensure UI is rendered
      Future.delayed(const Duration(milliseconds: 500), () {
        startRecording();
      });
    } catch (e) {
      setError('Error initializing recorder: $e');
    }
  }

  void setError(String message) {
    emit(state.copyWith(hasError: true, errorMessage: message));
  }

  Future<void> startRecording() async {
    if (!state.isInitialized) {
      setError('Recorder not initialized');
      return;
    }

    try {
      // Set recording parameters
      await _recorder.startRecorder(
        toFile: state.audioPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      emit(state.copyWith(isRecording: true, recordingDuration: 0));

      // Start a timer for recording duration
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final newDuration = state.recordingDuration + 1;
        emit(state.copyWith(recordingDuration: newDuration));

        // After specified duration, finish recording and proceed
        if (newDuration >= _totalDuration) {
          finishRecording();
        }
      });
    } catch (e) {
      setError('Error starting recording: $e');
    }
  }

  Future<void> pauseOrResumeRecording() async {
    if (!state.isRecording) return;

    try {
      if (_recorder.isPaused) {
        await _recorder.resumeRecorder();
      } else {
        await _recorder.pauseRecorder();
      }

      // Update state to trigger UI rebuild
      emit(state.copyWith());
    } catch (e) {
      debugPrint('Error pausing/resuming: $e');
      // We don't set error state here to allow recording to continue
    }
  }

  Future<void> finishRecording() async {
    if (!state.isRecording) return;

    _timer?.cancel();
    _timer = null;

    try {
      final String? path = await _recorder.stopRecorder();

      final audioPath = path ?? state.audioPath;

      // Verify the file exists and has content
      final file = File(audioPath);
      if (await file.exists() && await file.length() > 0) {
        emit(
          state.copyWith(
            isRecording: false,
            audioPath: audioPath,
            isRecordingComplete: true,
          ),
        );
      } else {
        setError('Recording failed: Empty or missing audio file');
      }
    } catch (e) {
      setError('Error finishing recording: $e');
    }
  }

  void skipRecording() {
    // Skip recording and proceed with empty audio path
    _timer?.cancel();
    _timer = null;

    if (state.isRecording) {
      _recorder
          .stopRecorder()
          .then((_) {
            emit(
              state.copyWith(
                isRecording: false,
                audioPath: '',
                isRecordingComplete: true,
              ),
            );
          })
          .catchError((e) {
            // Even if stopping fails, still indicate completion
            emit(
              state.copyWith(
                isRecording: false,
                audioPath: '',
                isRecordingComplete: true,
              ),
            );
          });
    } else {
      emit(
        state.copyWith(
          isRecording: false,
          audioPath: '',
          isRecordingComplete: true,
        ),
      );
    }
  }

  double get progress {
    return state.recordingDuration / _totalDuration;
  }

  bool get isRecorderPaused => _recorder.isPaused;

  String formatDuration() {
    final minutes = (state.recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.recordingDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String formatTotalDuration() {
    final minutes = (_totalDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_totalDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _recorder.closeRecorder();
    return super.close();
  }
}
