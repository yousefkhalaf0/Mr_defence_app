import 'dart:developer';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/widgets/show_alert.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/reports/data/models/report.dart';
import 'package:app/features/reports/data/repos/report_repos.dart';
import 'package:app/features/reports/presentation/manager/reports_cubit/reports_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<ReportsCubit>().changeTab(_tabController.index);
      }
    });

    log('ReportsView initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ReportsCubit(repository: ReportsRepository())..loadReports(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Reports'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                context.read<EmergencyCubit>().changePage(0);
              }
            },
          ),
        ),
        body: BlocConsumer<ReportsCubit, ReportsState>(
          listener: (context, state) {
            if (state is ReportsLoaded) {
              log(
                'Loaded reports: ${state.sentReports.length} sent, ${state.receivedReports.length} received',
              );
            } else if (state is ReportsFailed) {
              log('Error in reports_view: ${state.message}');
              showPopUpAlert(
                context: context,
                message: 'Something went wrong. Please try again.',
                icon: Icons.error_outline,
                color: kError,
              );
            } else if (state is ReportsClearingInProgress) {
              // Optionally show a loading indicator when clearing
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  indicatorWeight: 3,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Received Tab
                      _buildReportsList(context, state, isReceived: true),

                      // Sent Tab
                      _buildReportsList(context, state, isReceived: false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportsList(
    BuildContext context,
    ReportsState state, {
    required bool isReceived,
  }) {
    if (state is ReportsLoading || state is ReportsClearingInProgress) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ReportsFailed) {
      log('Error: ${state.message}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ReportsCubit>().loadReports();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state is ReportsLoaded) {
      final reports = isReceived ? state.receivedReports : state.sentReports;
      log(
        '${isReceived ? "Received" : "Sent"} reports count: ${reports.length}',
      );

      if (reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isReceived ? Icons.inbox : Icons.outbox,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${isReceived ? "received" : "sent"} reports found',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // Group reports by date
      final Map<String, List<Report>> groupedReports = {};
      for (var report in reports) {
        final date = _getDateGroup(report.occuredTime);
        if (!groupedReports.containsKey(date)) {
          groupedReports[date] = [];
        }
        groupedReports[date]!.add(report);
      }

      final sortedDates =
          groupedReports.keys.toList()..sort((a, b) {
            if (a == 'Today') return -1;
            if (b == 'Today') return 1;
            if (a == 'Yesterday') return -1;
            if (b == 'Yesterday') return 1;
            return 0;
          });

      return ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dateReports = groupedReports[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showClearConfirmationDialog(context, date, isReceived);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...dateReports.map((report) => _buildReportItem(context, report)),
            ],
          );
        },
      );
    }

    return const Center(child: Text('No data'));
  }

  void _showClearConfirmationDialog(
    BuildContext context,
    String dateGroup,
    bool isReceived,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Reports'),
            content: Text(
              'Are you sure you want to clear all $dateGroup reports?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ReportsCubit>().clearReportsByDate(
                    dateGroup,
                    isReceived,
                  );
                  showPopUpAlert(
                    context: context,
                    message: 'Reports cleared successfully',
                    icon: Icons.check_circle,
                    color: kSuccess,
                  );
                },
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildReportItem(BuildContext context, Report report) {
    final bool isSOS = report.requestType.toLowerCase() == 'sos';
    final Color statusColor = _getStatusColor(report.status);
    final String statusText = _getStatusText(report.status);

    return GestureDetector(
      onTap: () {
        // Navigate to report details
        if (isSOS) {
          log('Navigating to SOS report detail: ${report.id}');
          // Implementation for navigation
        } else {
          log('Navigating to Alert report detail: ${report.id}');
          // Implementation for navigation
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSOS ? Colors.red.shade100 : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Icon(
                  isSOS ? Icons.sos : Icons.notifications_active,
                  color: isSOS ? Colors.red : Colors.amber.shade800,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.userName.isNotEmpty
                        ? report.userName
                        : 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSOS
                        ? 'Immediate Assistance Required!'
                        : (report.description.isNotEmpty
                            ? report.description
                            : 'Alert notification'),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(report.occuredTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateGroup(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final reportDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reportDate == today) {
      return 'Today';
    } else if (reportDate == yesterday) {
      return 'Yesterday';
    } else {
      // Get day of week for reports within the last week
      final difference = today.difference(reportDate).inDays;
      if (difference < 7) {
        return DateFormat('EEEE').format(dateTime); // e.g., "Monday"
      } else {
        return DateFormat(
          'dd MMM yyyy',
        ).format(dateTime); // e.g., "15 Apr 2025"
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'pending':
      default:
        return Colors.amber.shade800;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}
