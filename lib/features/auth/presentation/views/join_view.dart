import 'package:flutter/material.dart';
import 'package:app/core/utils/router.dart';
import 'package:go_router/go_router.dart';

class JoinView extends StatelessWidget {
  const JoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).pushReplacement(AppRouter.kHomeView);
              },
              child: const Text('Join View', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
