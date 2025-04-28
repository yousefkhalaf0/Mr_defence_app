import 'dart:developer';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/core/utils/router.dart';
import 'package:app/core/widgets/show_pop_up_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/features/profile/presentation/views/add_contacts_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchSelectedContacts();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          log('DEBUG - Raw Firestore data: $data');

          setState(() {
            userData = data;
            _isLoading = false;
          });

          log('User data fetched successfully with ID: $userId');
          log('DEBUG - First name: ${userData['firstName']}');
          log('DEBUG - Last name: ${userData['lastName']}');
          log('DEBUG - Phone: ${userData['phoneNumber']}');
          log('DEBUG - Nationality: ${userData['nationality']}');
          log('DEBUG - Native Language: ${userData['nativeLanguage']}');
          // Check specifically for height field with different spellings
          log('DEBUG - Height field: ${userData['hieght'] ?? 'not found'}');
        } else {
          log('User document does not exist');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        log('User not logged in');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showPopUpAlert(
          context: context,
          message: 'Could not load profile data. Please try again.',
          icon: Icons.error,
          color: kError,
        );
      }
    }
  }

  Future<void> _fetchSelectedContacts() async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Get the current user document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Check if guardians array exists
          List<String> guardianIds = [];
          if (userData.containsKey('guardians') &&
              userData['guardians'] is List) {
            guardianIds = List<String>.from(userData['guardians']);
          }

          List<Map<String, dynamic>> contacts = [];

          // Fetch each guardian's data using their ID
          for (String guardianId in guardianIds) {
            DocumentSnapshot guardianDoc =
                await _firestore.collection('users').doc(guardianId).get();

            if (guardianDoc.exists &&
                guardianDoc.data() is Map<String, dynamic>) {
              Map<String, dynamic> guardianData =
                  guardianDoc.data() as Map<String, dynamic>;

              contacts.add({
                'id': guardianId,
                'name':
                    '${guardianData['firstName'] ?? ''} ${guardianData['lastName'] ?? ''}'
                        .trim(),
                'phoneNumber': guardianData['phoneNumber'] ?? 'No phone',
                'image': guardianData['profileImage'] ?? '',
              });
            }
          }

          setState(() {
            selectedContacts = contacts;
          });

          log('Fetched ${contacts.length} guardians');
        }
      }
    } catch (e) {
      log('Error fetching guardians: $e');
    }
  }

  // Add a new method to save selected contact to Firebase
  Future<void> _saveContactToFirebase(Contact contact) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Check if contact is registered in your app
        String contactPhone =
            contact.phones.isNotEmpty ? contact.phones.first.number : '';
        String? guardianId;

        // Clean the phone number for comparison
        String cleanedContactPhone = _cleanPhoneNumber(contactPhone);

        // Find if the phone number belongs to a registered user
        QuerySnapshot userSnapshot =
            await _firestore
                .collection('users')
                .where('phoneNumber', isEqualTo: contactPhone)
                .get();

        if (userSnapshot.docs.isEmpty) {
          // Try with cleaned phone
          userSnapshot = await _firestore.collection('users').get();

          // Manual comparison with cleaning
          for (var doc in userSnapshot.docs) {
            if (doc.data() is Map<String, dynamic>) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data.containsKey('phoneNumber') &&
                  _cleanPhoneNumber(data['phoneNumber']) ==
                      cleanedContactPhone) {
                guardianId = doc.id;
                break;
              }
            }
          }
        } else {
          guardianId = userSnapshot.docs.first.id;
        }

        // If no matching user found
        if (guardianId == null) {
          if (mounted) {
            showPopUpAlert(
              context: context,
              message: 'This contact is not registered in the app',
              icon: Icons.warning,
              color: kWarning,
            );
          }
          return;
        }

        // Get current user data to check existing guardians
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        List<dynamic> currentGuardians = [];

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('guardians') &&
              userData['guardians'] is List) {
            currentGuardians = userData['guardians'];
          }
        }

        // Check if guardian already exists
        if (currentGuardians.contains(guardianId)) {
          if (mounted) {
            showPopUpAlert(
              context: context,
              message: '${contact.displayName} in your guardians',
              icon: Icons.warning,
              color: kWarning,
            );
          }
          return;
        }

        // Add guardian ID to the array
        currentGuardians.add(guardianId);

        // Update the user document
        await _firestore.collection('users').doc(userId).update({
          'guardians': currentGuardians,
        });

        // Get guardian data for UI update
        DocumentSnapshot guardianDoc =
            await _firestore.collection('users').doc(guardianId).get();
        Map<String, dynamic> guardianData = {};

        if (guardianDoc.exists && guardianDoc.data() is Map<String, dynamic>) {
          guardianData = guardianDoc.data() as Map<String, dynamic>;
        }

        // Update the UI
        setState(() {
          selectedContacts.add({
            'id': guardianId,
            'name': contact.displayName,
            'phoneNumber': contactPhone,
            'image': guardianData['profileImage'] ?? '',
          });
        });

        if (mounted) {
          showPopUpAlert(
            context: context,
            message: '${contact.displayName} added to guardians',
            icon: Icons.check_circle,
            color: kSuccess,
          );
        }
      }
    } catch (e) {
      log('Error saving guardian: $e');
      if (mounted) {
        showPopUpAlert(
          context: context,
          message: 'Error saving guardian',
          icon: Icons.error,
          color: kError,
        );
      }
    }
  }

  String _cleanPhoneNumber(String phoneNumber) {
    // Trim spaces and clean up
    String cleanNumber = phoneNumber.trim();

    // Handle international prefix
    if (cleanNumber.startsWith('+')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // Remove all non-digit characters
    cleanNumber = cleanNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.startsWith('20') && cleanNumber.length > 10) {
      return cleanNumber;
    }

    if (cleanNumber.startsWith('002') && cleanNumber.length > 11) {
      cleanNumber = cleanNumber.substring(3);
    }

    return cleanNumber;
  }

  void _deleteContact(String guardianId) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Get current guardians array
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          List<dynamic> guardians = [];

          if (userData.containsKey('guardians') &&
              userData['guardians'] is List) {
            guardians = userData['guardians'];
          }

          // Remove the guardian ID
          guardians.remove(guardianId);

          // Update the user document
          await _firestore.collection('users').doc(userId).update({
            'guardians': guardians,
          });

          // Update the UI
          setState(() {
            selectedContacts.removeWhere(
              (contact) => contact['id'] == guardianId,
            );
          });

          if (mounted) {
            showPopUpAlert(
              context: context,
              message: 'Guardian removed successfully',
              icon: Icons.check_circle,
              color: kSuccess,
            );
          }
        }
      }
    } catch (e) {
      log('Error removing guardian: $e');
      if (mounted) {
        showPopUpAlert(
          context: context,
          message: 'Error removing guardian',
          icon: Icons.error,
          color: kError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future<String?> getProfilePhotoUrl() async {
    //   try {
    //     final user = FirebaseAuth.instance.currentUser;
    //     final userId = user?.uid;

    //     if (userId == null || userId.isEmpty) {
    //       log('User ID is null or empty');
    //       return null;
    //     }

    //     DocumentSnapshot<Map<String, dynamic>> snapshot =
    //         await FirebaseFirestore.instance
    //             .collection('users')
    //             .doc(userId)
    //             .get();

    //     if (!snapshot.exists) {
    //       log('User document does not exist');
    //       return null;
    //     }

    //     final data = snapshot.data();
    //     return data?['profileImage'];
    //   } catch (e) {
    //     log('Error fetching profile photo URL: $e');
    //     return null;
    //   }
    // }

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
          // IconButton(
          //   icon: Icon(Icons.settings, color: Colors.grey[700]),
          //   onPressed: () {
          //     GoRouter.of(context).push(AppRouter.kSetting);
          //   },
          // ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          const SizedBox(width: 16),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await _fetchUserData();
                  await _fetchSelectedContacts();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image and User Information Section
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => log("Avatar clicked"),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    userData['profileImage'] != null &&
                                            userData['profileImage']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(userData['profileImage'])
                                        : null,
                                child:
                                    userData['profileImage'] == null ||
                                            userData['profileImage']
                                                .toString()
                                                .isEmpty
                                        ? SvgPicture.asset(
                                          AssetsData.avatar,
                                          width: 110,
                                          height: 110,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}"
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData['phoneNumber'] ??
                                  "Add your phone number",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      sectionHeader(
                        "Basic Information",
                        bold: true,
                        onTap: () {
                          log("Edit info clicked");
                        },
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
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/gender.svg',
                                    "Gender",
                                    userData['gender'] ?? "Not set",
                                  ),
                                ),
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/birthdate.svg',
                                    "Birthdate",
                                    userData['birthDate'] ?? "Not set",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/height.svg',
                                    "Height",
                                    userData['hieght'] ?? "Not set",
                                  ),
                                ),
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/weight.svg',
                                    "Weight",
                                    userData['weight'] ?? "Not set",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/language.svg',
                                    "Native Language",
                                    userData['nativeLanguage'] ?? "Not set",
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/nationality.svg',
                                    "Nationality",
                                    userData['nationality'] ?? "Not set",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/id.svg',
                                    "ID",
                                    userData['nid'] ?? "Not set",
                                  ),
                                ),
                                Expanded(
                                  child: infoRowWithImage(
                                    'assets/profile_assets/icons/passport.svg',
                                    "Passport",
                                    userData['passport'] ?? "Not set",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            infoRowWithImage(
                              'assets/profile_assets/icons/driver.svg',
                              "Driver License",
                              userData['driverLicense'] ?? "Not set",
                            ),
                            const SizedBox(height: 16),
                            infoRowWithImage(
                              'assets/profile_assets/icons/email.svg',
                              "E-mail",
                              userData['email'] ?? "Not set",
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
                                  iconPath:
                                      'assets/profile_assets/images/BloodIcon.svg',
                                  buttonText:
                                      userData['bloodType'] != null &&
                                              userData['bloodType']
                                                  .toString()
                                                  .isNotEmpty
                                          ? userData['bloodType']
                                          : "Not set",
                                  buttonIconPath:
                                      'assets/profile_assets/images/Blood.svg',
                                  backgroundColor: Colors.white,
                                ),
                                buildHealthItem(
                                  label: "Wheelchair",
                                  iconPath:
                                      'assets/profile_assets/images/WheelIcon.svg',
                                  buttonText:
                                      userData['wheelchair'] == true
                                          ? "Yes"
                                          : "No",
                                  buttonIconPath:
                                      'assets/profile_assets/images/Wheel.svg',
                                  backgroundColor:
                                      userData['wheelchair'] == true
                                          ? const Color(0xFF86D5C8)
                                          : const Color(0xFFFD5B68),
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
                                  buttonText:
                                      userData['diabetes'] == true
                                          ? "Yes"
                                          : "No",
                                  buttonIconPath:
                                      'assets/profile_assets/images/Row_2.svg',
                                  backgroundColor:
                                      userData['diabetes'] == true
                                          ? const Color(0xFF86D5C8)
                                          : const Color(0xFFCECECE),
                                  borderColor: const Color(0xFF050A0D),
                                  borderWidth: 1,
                                ),
                                buildHealthItem(
                                  label: "Heart Disease",
                                  iconPath:
                                      'assets/profile_assets/images/HeartDisease.svg',
                                  buttonText:
                                      userData['heartDisease'] == true
                                          ? "Yes"
                                          : "No",
                                  buttonIconPath:
                                      'assets/profile_assets/images/Row_2.svg',
                                  backgroundColor:
                                      userData['heartDisease'] == true
                                          ? const Color(0xFF86D5C8)
                                          : const Color(0xFFCECECE),
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
                                  iconPath:
                                      'assets/profile_assets/images/Left.svg',
                                  buttonText:
                                      userData['scar'] != null &&
                                              userData['scar']
                                                  .toString()
                                                  .isNotEmpty
                                          ? userData['scar']
                                          : "Not set",
                                  buttonIconPath:
                                      'assets/profile_assets/images/RightArm.svg',
                                  backgroundColor: Colors.white,
                                ),
                                buildHealthItem(
                                  label: "Tattoo place",
                                  iconPath:
                                      'assets/profile_assets/images/Right.svg',
                                  buttonText:
                                      userData['tattoo'] != null &&
                                              userData['tattoo']
                                                  .toString()
                                                  .isNotEmpty
                                          ? userData['tattoo']
                                          : "Not set",
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
                                  onTap: () {
                                    log("Add Home clicked");
                                  },
                                  child: Column(
                                    children: [
                                      locationLabel("Home Location"),
                                      const SizedBox(height: 6),
                                      locationButton(
                                        userData['homeLocation'] != null
                                            ? "Home"
                                            : "Add home",
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    log("Add Work clicked");
                                  },
                                  child: Column(
                                    children: [
                                      locationLabel("Work Location"),
                                      const SizedBox(height: 6),
                                      locationButton(
                                        userData['workLocation'] != null
                                            ? "Work"
                                            : "Add work",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                log("Custom location clicked");
                              },
                              child: locationButton(
                                "Custom location",
                                isCustom: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      sectionHeader(
                        "Nearby Police Stations",
                        icon: Icons.wifi_tethering,
                        bold: true,
                        onTap: () {
                          log("Nearby stations clicked");
                        },
                      ),
                      policeCard("Police Station #1", "+91 0345-325-100"),
                      policeCard("Police Station #2", "+91 2352-356-999"),

                      const SizedBox(height: 20),
                      sectionHeader(
                        "My Contacts",
                        bold: true,
                        iconWidget: GestureDetector(
                          onTap: () {
                            _fetchSelectedContacts();
                          },
                          child: Image.asset(
                            'assets/profile_assets/images/RefreshIcon.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),

                      if (selectedContacts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "No contacts added yet",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ...selectedContacts.map((contact) {
                          return contactCard(
                            contact['name'] ?? "Unknown",
                            contact['phoneNumber'] ?? "No phone",
                            () => _deleteContact(contact['id']),
                            imageUrl: contact['image'],
                          );
                        }).toList(),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await GoRouter.of(
                              context,
                            ).push(AppRouter.kAddContact);

                            // If result is a Contact object, save it
                            if (result != null && result is Contact) {
                              await _saveContactToFirebase(result);
                              await _fetchSelectedContacts(); // Refresh contacts list
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
              onTap:
                  onTap ??
                  () {
                    log('$title clicked');
                  },
              child: Icon(icon, color: Colors.grey[600], size: 18),
            ),
        ],
      ),
    );
  }

  Widget infoRowWithImage(String imagePath, String label, String value) {
    bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: () => log("$label clicked"),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10.0,
          left: Helper.getResponsiveWidth(context, width: 6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFFFFF),
              ),
              child: Center(
                child:
                    isSvg
                        ? SvgPicture.asset(imagePath, width: 18, height: 18)
                        : Image.asset(imagePath, width: 18, height: 18),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7E7E),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                imageUrl != null && imageUrl.isNotEmpty
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
