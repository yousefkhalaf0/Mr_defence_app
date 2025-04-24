import 'package:app/core/utils/firebase_service.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  UserDataCubit() : super(UserDataInitial());

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      emit(UserDataLoading());

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(UserDataFailure('User not authenticated'));
        return;
      }

      await _firebaseService.createUserDocument(
        userId: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        birthDate: userData['birthDate'],
        nid: userData['nid'],
        passport: userData['passport'],
        driverLicense: userData['driverLicense'],
        height: userData['height'],
        weight: userData['weight'],
        bloodType: userData['bloodType'],
        wheelchair: userData['wheelchair'],
        diabetes: userData['diabetes'],
        heartDisease: userData['heartDisease'],
        tattoo: userData['tattoo'],
        scar: userData['scar'],
        nationality: userData['nationality'],
        nativeLanguage: userData['nativeLanguage'],
        gender: userData['gender'] ?? '',
        profileImage: userData['profileImage'] ?? '',
      );

      emit(UserDataSuccess());
    } catch (e) {
      emit(UserDataFailure(e.toString()));
    }
  }
}
