import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String phoneNumber,
    String? nid,
    String? name,
    String? birthDate,
    String? bloodType,
    String? gender,
    GeoPoint? homeLocation,
    GeoPoint? workLocation,
    String? nativeLanguage,
    String? email,
    List<String>? guardians,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'phoneNumber': phoneNumber,
      'nid': nid,
      'name': name,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'gender': gender,
      'homeLocation': homeLocation,
      'workLocation': workLocation,
      'nativeLanguage': nativeLanguage,
      'email': email,
      'guardians': guardians ?? [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user document
  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Check if user exists
  Future<bool> userExists(String phoneNumber) async {
    final query =
        await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }
}
