import 'dart:developer';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:app/features/profile/presentation/views/add_contacts_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> selectedContacts = [];

  void _deleteContact(int index) {
    setState(() {
      selectedContacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/profile_assets/images/BackIcon.png',
            width: 20,
            height: 20,
          ),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[700]),
            onPressed: () {
              GoRouter.of(context).pushReplacement(AppRouter.kSetting);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => log("Avatar clicked"),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        AssetsData.avatar,
                        width: 110,
                        height: 110,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Malak Haitham",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "+20 1219283723",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            sectionHeader(
              "Based information",
              icon: Icons.edit,
              bold: true,
              onTap: () => log("Edit info clicked"),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCECECE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      infoRowWithImage(
                        'assets/profile_assets/images/GenderIcon.png',
                        "Gender",
                        "female",
                      ),
                      const SizedBox(width: 40),
                      infoRow(Icons.cake, "Birthdate", "2/5/2002"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      infoRowWithImage(
                        'assets/profile_assets/images/IDIcon.png',
                        "ID",
                        "203067847465",
                      ),
                      const SizedBox(),
                      infoRowWithImage(
                        'assets/profile_assets/images/PassportIcon.png',
                        "Passport",
                        "2030678487465",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Health Details Section
            const SizedBox(height: 20),
            sectionHeader("Health Details", bold: true),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCECECE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildHealthItem(
                        label: "Blood Type",
                        iconPath: 'assets/profile_assets/images/BloodIcon.svg',
                        buttonText: "B+",
                        buttonIconPath:
                            'assets/profile_assets/images/Blood.svg',
                        backgroundColor: Colors.white,
                      ),
                      buildHealthItem(
                        label: "Wheelchair",
                        iconPath: 'assets/profile_assets/images/WheelIcon.svg',
                        buttonText: "Yes",
                        buttonIconPath:
                            'assets/profile_assets/images/Wheel.svg',
                        backgroundColor: const Color(0xFF86D5C8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildHealthItem(
                        label: "Diabetes",
                        iconPath:
                            'assets/profile_assets/images/DiabetesIcon.svg',
                        buttonText: "No",
                        buttonIconPath:
                            'assets/profile_assets/images/Row_2.svg',
                        backgroundColor: const Color(0xFFCECECE),
                        borderColor: const Color(0xFF050A0D),
                        borderWidth: 1,
                      ),
                      buildHealthItem(
                        label: "Heart Disease",
                        iconPath:
                            'assets/profile_assets/images/HeartDisease.svg',
                        buttonText: "No",
                        buttonIconPath:
                            'assets/profile_assets/images/Row_2.svg',
                        backgroundColor: const Color(0xFFCECECE),
                        borderColor: const Color(0xFF050A0D),
                        borderWidth: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Signs Details Section
            const SizedBox(height: 20),
            sectionHeader("Signs Details", bold: true),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCECECE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildHealthItem(
                        label: "Scar place",
                        iconPath: 'assets/profile_assets/images/Left.svg',
                        buttonText: "Right arm",
                        buttonIconPath:
                            'assets/profile_assets/images/RightArm.svg',
                        backgroundColor: Colors.white,
                      ),
                      buildHealthItem(
                        label: "tattoo place",
                        iconPath: 'assets/profile_assets/images/Right.svg',
                        buttonText: "Left arm",
                        buttonIconPath:
                            'assets/profile_assets/images/LeftArm.svg',
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            sectionHeader("Saved Locations", bold: true),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCECECE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => log("Add Home clicked"),
                        child: Column(
                          children: [
                            locationLabel("Home Location"),
                            const SizedBox(height: 6),
                            locationButton("Add home"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => log("Add Work clicked"),
                        child: Column(
                          children: [
                            locationLabel("Work Location"),
                            const SizedBox(height: 6),
                            locationButton("Add work"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => log("Custom location clicked"),
                    child: locationButton("Custom location", isCustom: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            sectionHeader(
              "Nearby Police Stations",
              icon: Icons.wifi_tethering,
              bold: true,
              onTap: () => log("Nearby stations clicked"),
            ),
            policeCard("Police Station #1", "+91 0345-325-100"),
            policeCard("Police Station #2", "+91 2352-356-999"),
            const SizedBox(height: 20),
            sectionHeader(
              "My Contacts",
              bold: true,
              iconWidget: GestureDetector(
                onTap: () => log("Refresh clicked"),
                child: Image.asset(
                  'assets/profile_assets/images/RefreshIcon.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            ...selectedContacts.map((contact) {
              int index = selectedContacts.indexOf(contact);
              return contactCard(
                contact['name']!,
                contact['phone']!,
                () => _deleteContact(index),
                imageUrl: contact['image'],
              );
            }),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddContactsPage(),
                    ),
                  );

                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      bool exists = selectedContacts.any(
                        (c) =>
                            c['name'] == result['name'] &&
                            c['phone'] == result['phone'],
                      );
                      if (!exists) {
                        selectedContacts.add(result);
                      }
                    });
                  }
                },
                icon: Image.asset(
                  'assets/profile_assets/images/PhoneIcon.png',
                  width: 18,
                  height: 18,
                ),
                label: const Text(
                  "Add Contact",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5B68),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(120, 55),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(
    String title, {
    IconData? icon,
    Widget? iconWidget,
    bool bold = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (iconWidget != null)
            iconWidget
          else if (icon != null)
            GestureDetector(
              onTap: onTap ?? () => log('$title clicked'),
              child: Icon(icon, color: Colors.grey[600], size: 18),
            ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return GestureDetector(
      onTap: () => log("$label clicked"),
      child: Padding(
        padding: EdgeInsets.only(
          left: Helper.getResponsiveWidth(context, width: 8),
          bottom: 10.0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(icon, color: Colors.grey[800], size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRowWithImage(String imagePath, String label, String value) {
    final bool isPassport = label.toLowerCase() == "passport";
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth < 360 ? 10.0 : 12.0;
    final valueFontSize = screenWidth < 360 ? 10.0 : 12.0;

    return GestureDetector(
      onTap: () => log("$label clicked"),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10.0,
          left: Helper.getResponsiveWidth(context, width: 6),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(imagePath, width: 18, height: 18),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isPassport ? baseFontSize : 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isPassport ? valueFontSize : 12,
                    color: const Color(0xFF7E7E7E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHealthItem({
    required String label,
    required String iconPath,
    required String buttonText,
    required Color backgroundColor,
    String? buttonIconPath,
    Color borderColor = Colors.transparent,
    double borderWidth = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 135,
          child: GestureDetector(
            onTap: () => log("Clicked on label: $label"),
            child: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 14,
                  height: 14,
                  color: const Color(0xFF74797B),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF74797B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => log("Clicked on button: $buttonText"),
          child: Container(
            width: 135,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonIconPath != null) ...[
                  SvgPicture.asset(
                    buttonIconPath,
                    width: 16,
                    height: 16,
                    color: const Color(0xFF050A0D),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF050A0D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget locationButton(
    String label, {
    bool fullWidth = false,
    bool isCustom = false,
  }) {
    return Container(
      width: isCustom ? 150 : (fullWidth ? double.infinity : 135),
      height: 48,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: isCustom ? Colors.white : Colors.grey[400]!),
        borderRadius: BorderRadius.circular(17),
        color: isCustom ? const Color(0xFFCECECE) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/profile_assets/images/PlusIcon.png',
            width: 16,
            height: 16,
            color: isCustom ? Colors.white : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isCustom ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget locationLabel(String text) {
    return Container(
      width: 135,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.0,
          letterSpacing: -0.32,
          color: Color(0xFF74797B),
        ),
      ),
    );
  }

  Widget policeCard(String title, String phone) {
    return GestureDetector(
      onTap: () => log("$title clicked"),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Color(0xFF7E7E7E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => log("More options for $title"),
              child: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactCard(
    String name,
    String phone,
    VoidCallback onDelete, {
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage:
                imageUrl != null
                    ? NetworkImage(imageUrl)
                    : const NetworkImage(
                      'https://www.w3schools.com/howto/img_avatar.png',
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(color: Color(0xFF667085))),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Image.asset(
              'assets/profile_assets/images/DeleteIcon.png',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
