import 'dart:async';
import 'package:app/core/utils/firebase_service.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final FirebaseService _firebaseService;
  Timer? _resendTimer;

  PhoneAuthCubit(this._firebaseService) : super(PhoneAuthInitial());

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(PhoneAuthLoading());
    try {
      await _firebaseService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: _onVerificationCompleted,
        onVerificationFailed: (FirebaseAuthException e) {
          if (e.code == 'quota-exceeded') {
            emit(
              PhoneAuthFailure('SMS quota exceeded. Please try again later.'),
            );
          } else if (e.code == 'billing-not-enabled') {
            emit(
              PhoneAuthFailure(
                'Authentication service not properly configured',
              ),
            );
          } else {
            emit(PhoneAuthFailure(e.message ?? 'Phone verification failed'));
          }
        },
        onCodeSent: _onCodeSent,
        onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
      );
      _startResendTimer();
    } catch (e) {
      emit(PhoneAuthFailure(e.toString()));
    }
  }

  Future<void> verifyOtpCode(String otpCode) async {
    final verificationId = _firebaseService.verificationId;
    if (verificationId == null) {
      emit(PhoneAuthFailure('Verification ID not found'));
      return;
    }

    emit(PhoneAuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      final userCredential = await _firebaseService.signInWithCredential(
        credential,
      );
      emit(PhoneAuthSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(PhoneAuthFailure(e.message ?? 'OTP verification failed'));
    } catch (e) {
      emit(PhoneAuthFailure(e.toString()));
    }
  }

  // void resendCode(String phoneNumber) {
  //   if (state is! PhoneAuthResendAvailable) return;

  //   _resendTimer?.cancel();
  //   verifyPhoneNumber(phoneNumber);
  // }

  Future<void> resendCode(String phoneNumber) async {
    emit(PhoneAuthLoading());
    try {
      await _firebaseService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: _onVerificationCompleted,
        onVerificationFailed: _onVerificationFailed,
        onCodeSent: _onCodeSent,
        onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
        forceResendingToken: _firebaseService.resendToken,
      );
    } catch (e) {
      emit(PhoneAuthFailure(e.toString()));
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _firebaseService.signInWithCredential(
        credential,
      );
      emit(PhoneAuthSuccess(userCredential.user!));
    } catch (e) {
      emit(PhoneAuthFailure(e.toString()));
    }
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    emit(PhoneAuthFailure(e.message ?? 'Phone verification failed'));
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    _firebaseService.cacheVerificationData(verificationId, resendToken);
    emit(PhoneAuthCodeSent(verificationId));
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    emit(PhoneAuthCodeRetrievalTimedOut());
  }

  void _startResendTimer() {
    const resendDelay = Duration(seconds: 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = resendDelay - Duration(seconds: timer.tick);
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        emit(PhoneAuthResendAvailable(Duration.zero));
      } else {
        emit(PhoneAuthResendAvailable(remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
