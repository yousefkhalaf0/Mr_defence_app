import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/features/home/presentation/manager/cubit/emergency_cubit.dart';
import 'package:app/features/home/presentation/views/alert_view.dart';
import 'package:app/features/home/presentation/views/sos_view.dart';
import 'package:app/features/community/presentation/views/community.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmergencyCubit(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AlertView(),
      const SosView(),
      const CommunityView(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsData.appLogoInHomepage,
              height: Helper.getResponsiveHeight(context, height: 47),
              width: Helper.getResponsiveWidth(context, width: 47),
            ),
            Text(
              "MR. DEFENCE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: kPrimary700.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
                fontSize: Helper.getResponsiveFontSize(context, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          SvgPicture.asset(
            AssetsData.notificationWithCircle,
            height: Helper.getResponsiveHeight(context, height: 27),
            width: Helper.getResponsiveWidth(context, width: 27),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: IconButton(
              icon: SvgPicture.asset(AssetsData.avatar, fit: BoxFit.cover),
              onPressed: () {
                GoRouter.of(context).push(AppRouter.kProfilePage);
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<EmergencyCubit, EmergencyState>(
        builder: (context, state) {
          return pages[state.currentPageIndex];
        },
      ),
    );
  }
}
