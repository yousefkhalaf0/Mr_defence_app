import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout, int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
    );
  }

  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await _auth.signInWithCredential(credential);
  }

  Future<void> cacheVerificationData(
    String verificationId,
    int? resendToken,
  ) async {
    _verificationId = verificationId;
    _resendToken = resendToken;
  }

  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;

  User? get currentUser => _auth.currentUser;
  Future<void> signOut() async => await _auth.signOut();
}
