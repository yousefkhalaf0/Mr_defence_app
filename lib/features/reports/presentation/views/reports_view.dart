import 'dart:developer';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/core/widgets/show_pop_up_alert.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/reports/data/models/report.dart';
import 'package:app/features/reports/data/repos/report_repos.dart';
import 'package:app/features/reports/presentation/manager/reports_cubit/reports_cubit.dart';
import 'package:app/features/reports/presentation/views/response_view/response_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
  final Set<String> _selectedReports = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<ReportsCubit>().changeTab(_tabController.index);
        if (_isSelectionMode) {
          _exitSelectionMode();
        }
      }
    });

    log('ReportsView initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _enterSelectionMode(String reportId) {
    setState(() {
      _isSelectionMode = true;
      _selectedReports.add(reportId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedReports.clear();
    });
  }

  void _toggleReportSelection(String reportId) {
    setState(() {
      if (_selectedReports.contains(reportId)) {
        _selectedReports.remove(reportId);
        if (_selectedReports.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedReports.add(reportId);
      }
    });
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
          title:
              !_isSelectionMode
                  ? Text(
                    'Reports',
                    style: Styles.textStyle20(
                      context,
                    ).copyWith(color: kGradientColor1),
                  )
                  : Text(
                    '${_selectedReports.length} Selected',
                    style: Styles.textStyle20(
                      context,
                    ).copyWith(color: kGradientColor1),
                  ),
          centerTitle: true,
          leading:
              !_isSelectionMode
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        GoRouter.of(context).pop();
                      } else {
                        context.read<EmergencyCubit>().changePage(0);
                      }
                    },
                  )
                  : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _exitSelectionMode,
                  ),
          actions:
              _isSelectionMode
                  ? [
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: kError,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context);
                      },
                    ),
                  ]
                  : null,
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
            } else if (state is ReportsDeleteSuccess) {
              _exitSelectionMode();
              showPopUpAlert(
                context: context,
                message: 'Reports deleted successfully',
                icon: Icons.check_circle,
                color: kSuccess,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
                  labelStyle: Styles.textStyle16(
                    context,
                  ).copyWith(color: kPrimary900),
                  indicatorWeight: 3,
                  indicatorColor: kPrimary900,
                  unselectedLabelColor: kNeutral600,
                  indicatorSize: TabBarIndicatorSize.tab,
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
    if (state is ReportsLoading ||
        state is ReportsClearingInProgress ||
        state is ReportsDeleting) {
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
                size: 70,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${isReceived ? "received" : "sent"} reports found',
                style: Styles.textStyle18(
                  context,
                ).copyWith(color: kNeutral400, fontWeight: FontWeight.normal),
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
                child: Text(
                  date,
                  style: Styles.textStyle18(
                    context,
                  ).copyWith(color: kNeutral400, fontWeight: FontWeight.normal),
                ),
              ),
              ...dateReports.map(
                (report) =>
                    _buildReportItem(context, report, isReceived: isReceived),
              ),
            ],
          );
        },
      );
    }

    return const Center(child: Text('No data'));
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final isReceived = _tabController.index == 0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reports'),
            content: Text(
              'Are you sure you want to delete ${_selectedReports.length} selected ${isReceived ? "received" : "sent"} reports?',
            ),
            actions: [
              TextButton(
                onPressed: () => GoRouter.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  GoRouter.of(context).pop();
                  context.read<ReportsCubit>().deleteSelectedReports(
                    _selectedReports.toList(),
                    isReceived,
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    Report report, {
    required bool isReceived,
  }) {
    final bool isSOS = report.requestType.toLowerCase() == 'sos';
    final Color statusColor = _getStatusColor(report.status);
    final String statusText = _getStatusText(report.status);

    final bool isSelected = _selectedReports.contains(report.id);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleReportSelection(report.id);
        } else {
          _navigateToReportDetails(context, report);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          _enterSelectionMode(report.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (_isSelectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _toggleReportSelection(report.id);
                },
              ),
            isSOS
                ? SvgPicture.asset(AssetsData.sosLogoIcon, width: 55)
                : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.amber.shade800,
                      size: 28,
                    ),
                  ),
                ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.userName.isNotEmpty
                        ? report.userName
                        : 'Unknown User',
                    style: Styles.textStyle16(context),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isSOS
                        ? 'Immediate Assistance Required!'
                        : (report.description.isNotEmpty
                            ? report.description
                            : 'Alert request!'),
                    style:
                        isSOS
                            ? Styles.textStyle14(context).copyWith(
                              color: kEmergency600,
                              fontWeight: FontWeight.bold,
                            )
                            : Styles.textStyle14(
                              context,
                            ).copyWith(color: kNeutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        statusText,
                        style: Styles.textStyle12(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(report.occuredTime),
                        style: Styles.textStyle14(
                          context,
                        ).copyWith(color: kNeutral400),
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
      final difference = today.difference(reportDate).inDays;
      if (difference < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('dd MMM yyyy').format(dateTime);
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return kOpen;
      case 'closed':
        return kClosed;
      case 'pending':
      default:
        return kPending;
    }
  }

  void _navigateToReportDetails(BuildContext context, Report report) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmergencyRequestDetailsView(report: report),
      ),
    );

    // If changes were made in the details view, refresh the reports
    if (result == true) {
      context.read<ReportsCubit>().loadReports();
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
