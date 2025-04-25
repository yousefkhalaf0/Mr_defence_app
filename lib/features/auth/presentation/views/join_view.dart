import 'package:app/core/utils/constants.dart';
import 'package:app/features/auth/presentation/views/widgets/join_view_body.dart';
import 'package:flutter/material.dart';

class JoinView extends StatelessWidget {
  const JoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kNeutral500,
      body: SafeArea(child: JoinViewBody()),
    );
  }
}
