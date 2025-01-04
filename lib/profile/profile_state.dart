part of 'profile_cubit.dart';


@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class PasswordChanged extends ProfileState {}


class UserLoaded extends ProfileState {
  final Student user;
  UserLoaded(this.user);
}

class UserUpdated extends ProfileState {
  final Student user;
  UserUpdated(this.user);
}


class ProfileError extends ProfileState {
  final String errorMessage;
  ProfileError(this.errorMessage);
}