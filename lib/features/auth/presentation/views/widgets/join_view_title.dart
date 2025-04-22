import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';

class JoinViewTitle extends StatelessWidget {
  const JoinViewTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Validate your phone', style: Styles.textStyle27(context)),
    );
  }
}
