import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const VerificationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          GoRouter.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back_rounded, color: kNeutral950),
      ),
      centerTitle: true,
      title: Text('Verification', style: Styles.textStyle24(context)),
    );
  }
}
