import 'dart:async';
import 'dart:developer';
import 'package:app/features/reports/data/models/report.dart';
import 'package:app/features/reports/data/repos/report_repos.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;
  StreamSubscription? _sentReportsSubscription;
  StreamSubscription? _receivedReportsSubscription;

  ReportsCubit({required ReportsRepository repository})
    : _repository = repository,
      super(ReportsInitial());

  void loadReports() {
    emit(ReportsLoading());

    // Load sent reports
    _sentReportsSubscription?.cancel();
    _sentReportsSubscription = _repository.getSentReports().listen(
      (sentReports) {
        final currentState = state;
        if (currentState is ReportsLoaded) {
          emit(currentState.copyWith(sentReports: sentReports));
        } else {
          emit(
            ReportsLoaded(sentReports: sentReports, receivedReports: const []),
          );
        }
        log('Sent reports loaded: ${sentReports.length}');
      },
      onError: (error) {
        log('Error loading sent reports: $error');
        emit(ReportsFailed(error.toString()));
      },
    );

    // Load received reports
    _receivedReportsSubscription?.cancel();
    _receivedReportsSubscription = _repository.getReceivedReports().listen(
      (receivedReports) {
        final currentState = state;
        if (currentState is ReportsLoaded) {
          emit(currentState.copyWith(receivedReports: receivedReports));
        } else {
          emit(
            ReportsLoaded(
              sentReports: const [],
              receivedReports: receivedReports,
            ),
          );
        }
        log('Received reports loaded: ${receivedReports.length}');
      },
      onError: (error) {
        log('Error loading received reports: $error');
        emit(ReportsFailed(error.toString()));
      },
    );
  }

  void changeTab(int index) {
    log('Changing tab to: $index');
    final currentState = state;
    if (currentState is ReportsLoaded) {
      emit(currentState.copyWith(currentTabIndex: index));
    }
  }

  Future<void> clearReportsByDate(String dateGroup, bool isReceived) async {
    try {
      emit(ReportsClearingInProgress());
      await _repository.clearReportsByDate(dateGroup, isReceived);
      // Reload reports after clearing
      loadReports();
    } catch (e) {
      log('Error clearing reports: $e');
      emit(ReportsFailed('Failed to clear reports: ${e.toString()}'));
    }
  }

  Future<void> deleteSelectedReports(
    List<String> reportIds,
    bool isReceived,
  ) async {
    try {
      emit(ReportsDeleting());
      await _repository.deleteSelectedReports(reportIds, isReceived);
      emit(ReportsDeleteSuccess());
      // Reload reports after deletion
      loadReports();
    } catch (e) {
      log('Error deleting reports: $e');
      emit(ReportsFailed('Failed to delete reports: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _sentReportsSubscription?.cancel();
    _receivedReportsSubscription?.cancel();
    return super.close();
  }
}
