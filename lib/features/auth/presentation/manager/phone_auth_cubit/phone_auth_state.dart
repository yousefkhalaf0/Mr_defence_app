part of 'phone_auth_cubit.dart';

@immutable
sealed class PhoneAuthState {}

final class PhoneAuthInitial extends PhoneAuthState {}

final class PhoneAuthLoading extends PhoneAuthState {}

final class PhoneAuthCodeSent extends PhoneAuthState {}

final class PhoneAuthVerified extends PhoneAuthState {
  final String userId;
  PhoneAuthVerified(this.userId);
}

final class PhoneAuthError extends PhoneAuthState {
  final String message;
  PhoneAuthError(this.message);
}
