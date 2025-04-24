import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      backgroundColor: const Color(0xFFE0E0E0),
      body: Column(
        children: [
          // Custom AppBar Area
          Container(
            width: 392,
            height: 55,
            margin: const EdgeInsets.only(top: 18),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/main');
                    },
                    child: const Icon(Icons.close, size: 28),
                  ),
                ),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar Section
          Container(
            width: 393,
            height: 48,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 4,
                  ),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0,
              ),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: SizedBox(
                      width: 196.5,
                      height: 48,
                      child: Center(
                          child: Text('All', textAlign: TextAlign.center)),
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
                          child: Text('Ongoing', textAlign: TextAlign.center)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content for each tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Outcoming Tab Content
                _buildEmptyNotificationContent(),
                // Sent Tab Content
                _buildEmptyNotificationContent(),
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
              // ignore: use_full_hex_values_for_flutter_colors
              color: Color(0x4FFFFC1B6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/notifications/images/NotifIcon.svg',
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
                  text: 'No notifications yet',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "You don’t have any notifications at this time.\nPlease check back later!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 20 / 15,
              letterSpacing: -0.4,
              color: Color(0xFF525252),
            ),
          ),
        ],
      ),
    );
  }
}
