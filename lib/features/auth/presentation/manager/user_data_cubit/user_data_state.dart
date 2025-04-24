part of 'user_data_cubit.dart';

@immutable
sealed class UserDataState {}

final class UserDataInitial extends UserDataState {}

class UserDataLoading extends UserDataState {}

class UserDataSuccess extends UserDataState {}

class UserDataFailure extends UserDataState {
  final String errorMessage;

  UserDataFailure(this.errorMessage);
}
