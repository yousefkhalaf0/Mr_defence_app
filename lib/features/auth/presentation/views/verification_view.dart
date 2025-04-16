import 'package:app/core/utils/constants.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_app_bar.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra as Map<String, String>?;
    if (args == null ||
        args['phone'] == null ||
        args['verificationId'] == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid verification flow')),
      );
    }

    return Scaffold(
      backgroundColor: kNeutral500,
      appBar: const VerificationAppBar(),
      body: VerificationViewBody(
        phone: args['phone']!,
        verificationId: args['verificationId']!,
      ),
    );
  }
}
