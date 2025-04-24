import 'package:app/core/utils/cache.dart';
import 'package:app/core/utils/enums.dart';
import 'package:app/core/utils/firebase_service.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  PhoneAuthCubit(this._firebaseService) : super(PhoneAuthInitial());

  final FirebaseService _firebaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  String? _phoneNumber;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(PhoneAuthLoading());
    _phoneNumber = phoneNumber;

    await _firebaseService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        emit(PhoneAuthCodeSent());
      },
      onVerificationFailed: (error) {
        emit(PhoneAuthError(error.message ?? 'Verification failed'));
      },
      onVerificationCompleted: (credential) async {
        await _handleVerificationCompleted(credential);
      },
      onCodeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifySmsCode(String smsCode) async {
    emit(PhoneAuthLoading());
    try {
      if (_verificationId == null || _phoneNumber == null) {
        throw Exception('Verification process not started');
      }

      final credential = await _firebaseService.signInWithPhoneCredential(
        _verificationId!,
        smsCode,
      );

      // Check if user exists in Firestore
      final userExists = await _firebaseService.userExists(_phoneNumber!);

      if (!userExists) {
        // Create new user document with minimal data
        await _firebaseService.createUserDocument(
          userId: credential.user!.uid,
          phoneNumber: _phoneNumber!,
        );
      }

      // Save phone number locally
      await MyShared.setString(
        key: MySharedKeys.userPhoneNumber,
        value: _phoneNumber!,
      );

      emit(PhoneAuthVerified(credential.user!.uid));
    } catch (e) {
      emit(PhoneAuthError(e.toString()));
    }
  }

  Future<void> _handleVerificationCompleted(
    PhoneAuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      emit(PhoneAuthVerified(userCredential.user!.uid));
    } catch (e) {
      emit(PhoneAuthError(e.toString()));
    }
  }
}
