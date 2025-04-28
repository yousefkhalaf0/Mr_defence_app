import 'package:app/core/utils/router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/reports/presentation/views/reports_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/features/home/presentation/manager/emergency_cubit/emergency_cubit.dart';
import 'package:app/features/home/presentation/views/alert_view.dart';
import 'package:app/features/home/presentation/views/sos_view.dart';
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

final defultEmergency = EmergencyType(
  name: 'notSelected',
  iconPath: AssetsData.customAlertType,
  backgroundColor: const Color(0xffC4912A),
);

class _HomePageView extends StatelessWidget {
  const _HomePageView();
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AlertView(),
      const SosButtonPage(),
      const ReportsView(),
    ];
    Future<String?> getProfilePhotoUrl() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid;

        if (userId == null || userId.isEmpty) {
          print('User ID is null or empty');
          return null;
        }

        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (!snapshot.exists) {
          print('User document does not exist');
          return null;
        }

        // Check multiple possible field names for profile image
        final data = snapshot.data();
        return data?['profileImage'] ??
            data?['profilePhotoUrl'] ??
            data?['photoURL'];
      } catch (e) {
        print('Error fetching profile photo URL: $e');
        return null;
      }
    }

    return BlocBuilder<EmergencyCubit, EmergencyState>(
      builder: (context, state) {
        return Scaffold(
          appBar:
              state.currentPageIndex != pages.length - 1
                  ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: null,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetsData.appLogoInHomepage,
                          height: Helper.getResponsiveHeight(
                            context,
                            height: 47,
                          ),
                          width: Helper.getResponsiveWidth(context, width: 47),
                          fit: BoxFit.cover,
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
                            fontSize: Helper.getResponsiveFontSize(
                              context,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      FutureBuilder<String?>(
            future: getProfilePhotoUrl(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: SizedBox(
                    width: Helper.getResponsiveHeight(context, height: 20),
                    height: Helper.getResponsiveWidth(context, width: 20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimary700,
                    ),
                  ),
                );
              }

              final photoUrl = snapshot.data;
              final hasValidPhoto = photoUrl != null && photoUrl.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  GoRouter.of(context).push(AppRouter.kProfilePage);
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      hasValidPhoto ? NetworkImage(photoUrl) : null,
                  child:
                      !hasValidPhoto
                          ? SvgPicture.asset(
                            AssetsData.avatar,
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      
      body: BlocBuilder<EmergencyCubit, EmergencyState>(
        builder: (context, state) {
          return pages[state.currentPageIndex];
        },
      ),
        );
      },
    );
  }
}
