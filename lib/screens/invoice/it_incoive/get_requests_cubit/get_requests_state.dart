part of 'get_requests_cubit.dart';

@immutable
sealed class GetRequestsState {}

final class GetRequestsInitial extends GetRequestsState {}

final class GetRequestsLoading extends GetRequestsState {}

final class GetRequestsLoaded extends GetRequestsState {
  final List<Request> requests;
  GetRequestsLoaded(this.requests);
}

final class GetRequestsError extends GetRequestsState {
  final String message;
  GetRequestsError(this.message);
}
