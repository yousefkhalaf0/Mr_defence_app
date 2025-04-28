part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> sentReports;
  final List<Report> receivedReports;
  final int currentTabIndex;

  const ReportsLoaded({
    required this.sentReports,
    required this.receivedReports,
    this.currentTabIndex = 0,
  });

  @override
  List<Object> get props => [sentReports, receivedReports, currentTabIndex];

  ReportsLoaded copyWith({
    List<Report>? sentReports,
    List<Report>? receivedReports,
    int? currentTabIndex,
  }) {
    return ReportsLoaded(
      sentReports: sentReports ?? this.sentReports,
      receivedReports: receivedReports ?? this.receivedReports,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

class ReportsClearingInProgress extends ReportsState {}

class ReportsDeleting extends ReportsState {}

class ReportsDeleteSuccess extends ReportsState {}

class ReportsFailed extends ReportsState {
  final String message;

  const ReportsFailed(this.message);

  @override
  List<Object> get props => [message];
}
