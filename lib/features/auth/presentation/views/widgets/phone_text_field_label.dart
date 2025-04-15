import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';

class PhoneTextFieldLabel extends StatelessWidget {
  const PhoneTextFieldLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Phone number',
        style: TextStyle(
          fontSize: Helper.getResponsiveFontSize(context, fontSize: 13),
          color: kNeutral800,
        ),
      ),
    );
  }
}
