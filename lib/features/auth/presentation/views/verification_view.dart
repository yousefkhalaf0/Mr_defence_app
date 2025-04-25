import 'package:app/core/utils/constants.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_app_bar.dart';
import 'package:app/features/auth/presentation/views/widgets/verification_view_body.dart';
import 'package:flutter/material.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kNeutral500,
      appBar: VerificationAppBar(),
      body: VerificationViewBody(),
    );
  }
}
