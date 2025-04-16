part of 'phone_auth_cubit.dart';

@immutable
sealed class PhoneAuthState {}

final class PhoneAuthInitial extends PhoneAuthState {}

final class PhoneAuthLoading extends PhoneAuthState {}

final class PhoneAuthCodeSent extends PhoneAuthState {
  final String verificationId;
  PhoneAuthCodeSent(this.verificationId);
}

final class PhoneAuthSuccess extends PhoneAuthState {
  final User user;
  PhoneAuthSuccess(this.user);
}

final class PhoneAuthFailure extends PhoneAuthState {
  final String message;
  PhoneAuthFailure(this.message);
}

final class PhoneAuthCodeRetrievalTimedOut extends PhoneAuthState {}

final class PhoneAuthResendAvailable extends PhoneAuthState {
  final Duration resendDelay;
  PhoneAuthResendAvailable(this.resendDelay);
}
