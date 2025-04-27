import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatefulWidget {
  final bool hasData;

  const ReportsScreen({super.key, this.hasData = true});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> todayReports = [
    {
      'name': 'Sarah Ahmed',
      'desc': 'Issue with the system',
      'status': 'Open',
      'time': '5m',
    },
    {
      'name': 'Mohamed Ali',
      'desc': 'Login error',
      'status': 'Closed',
      'time': '10m',
    },
    {
      'name': 'Amina Nour',
      'desc': 'Performance issue',
      'status': 'Open',
      'time': '2m',
    },
  ];

  final List<Map<String, String>> thursdayReports = [
    {
      'name': 'Youssef Adel',
      'desc': 'Email not syncing',
      'label': 'Resolved in',
      'time': '30m',
    },
    {
      'name': 'Laila Saeed',
      'desc': 'Crash on report',
      'label': 'Time spent',
      'time': '15m',
    },
    {
      'name': 'Laila Saeed',
      'desc': 'Crash on report',
      'label': 'Time spent',
      'time': '15m',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).go(AppRouter.kHomeView);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: 393,
            height: 48,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 4),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 20 / 14,
              ),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: SizedBox(
                      width: 196.5,
                      height: 48,
                      child: Center(
                        child: Text('Receive', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: SizedBox(
                      width: 196.5,
                      height: 48,
                      child: Center(
                        child: Text('Sent', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                widget.hasData
                    ? _buildReportDataContent()
                    : _buildEmptyNotificationContent(),
                widget.hasData
                    ? _buildReportDataContent()
                    : _buildEmptyNotificationContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDataContent() {
    return SingleChildScrollView(
      child: Container(
        width: 377,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            _buildDataFrame(
              title: 'Today',
              items:
                  todayReports.map((data) {
                    return _buildReportItem(
                      data['name']!,
                      data['desc']!,
                      data['status']!,
                      data['time']!,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            _buildDataFrame(
              title: 'Thursday',
              items:
                  thursdayReports.map((data) {
                    return _buildSecondFrameItem(
                      data['name']!,
                      data['desc']!,
                      data['label']!,
                      data['time']!,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataFrame({required String title, required List<Widget> items}) {
    return Container(
      width: 361,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF969696),
                ),
              ),
              const Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFFF725E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReportItem(
    String name,
    String description,
    String status,
    String time,
  ) {
    final isOpen = status.toLowerCase() == 'open';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFFDBE790),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/notifications/images/BagIcon.svg',
                width: 26.76,
                height: 25.61,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$status - ',
                      style: TextStyle(
                        // ignore: prefer_const_constructors
                        color: isOpen ? Colors.green : Color(0xFF982D21),

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF969696),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondFrameItem(
    String name,
    String description,
    String label,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFFBFBFBF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/notifications/images/CommentIcon.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$label: ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF969696),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotificationContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 59.58,
            height: 59.58,
            decoration: const BoxDecoration(
              color: Color(0xFFDBE790),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/notifications/images/NoRepertIcon.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              children: [
                TextSpan(
                  text: 'Oops! ',
                  style: TextStyle(color: Color(0xFFFB6A6A)),
                ),
                TextSpan(
                  text: 'No Report yet',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "You don’t have any report at this time.\nPlease check back later!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF525252),
            ),
          ),
        ],
      ),
    );
  }
}
