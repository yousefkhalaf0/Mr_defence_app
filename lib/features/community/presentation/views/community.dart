import 'package:app/core/widgets/the_nav_bar.dart';
import 'package:flutter/material.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: const Center(child: CustomNavBar()),
    );
  }
}
