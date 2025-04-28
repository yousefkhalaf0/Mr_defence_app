// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/widgets/show_pop_up_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class ContactWithStatus {
  final Contact contact;
  final bool isRegistered;

  ContactWithStatus({required this.contact, required this.isRegistered});
}

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  final Map<String, List<ContactWithStatus>> _groupedRegisteredContacts = {};
  final Map<String, List<ContactWithStatus>> _groupedNonRegisteredContacts = {};
  final List<Contact> _phoneContacts = [];
  final List<String> _appRegisteredPhones = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ContactWithStatus? _selectedContact;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load all required data in sequence
  Future<void> _loadData() async {
    try {
      await _fetchRegisteredUsers();
      await _fetchContacts();
    } catch (e) {
      log('Error loading data: $e');
      if (mounted) {
        showPopUpAlert(
          context: context,
          message: 'Error loading contacts data',
          icon: Icons.error,
          color: kError,
        );
      }
    }
  }

  // Fetch registered users from Firestore
  Future<void> _fetchRegisteredUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      final List<String> phones = [];
      log('--- Registered Phone Numbers from Firebase ---');

      for (var doc in usersSnapshot.docs) {
        if (doc.data().containsKey('phoneNumber')) {
          String phone = doc.data()['phoneNumber'] as String? ?? '';
          if (phone.isNotEmpty) {
            log('Firebase phone number (original): $phone');
            log('Firebase phone number (cleaned): ${_cleanPhoneNumber(phone)}');
            phones.add(phone);
          }
        }
      }

      if (mounted) {
        setState(() {
          _appRegisteredPhones.clear();
          _appRegisteredPhones.addAll(phones);
        });
      }
    } catch (e) {
      log('Error fetching registered users: $e');
      if (mounted) {
        setState(() {
          _appRegisteredPhones.clear();
        });
      }
    }
  }

  // Fetch contacts from device with permission check
  Future<void> _fetchContacts() async {
    final status = await Permission.contacts.request();

    if (status.isGranted) {
      try {
        final fetchedContacts = await FlutterContacts.getContacts(
          withPhoto: true,
          withProperties: true,
        );

        if (mounted) {
          setState(() {
            _phoneContacts.clear();
            _phoneContacts.addAll(fetchedContacts);
            _processContacts();
            _isLoading = false;
          });
        }
      } catch (e) {
        log('Error fetching contacts: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showPopUpAlert(
          context: context,
          message: 'You need to allow contacts access to use this feature',
          icon: Icons.error,
          color: kError,
        );
      }
    }
  }

  // Process contacts and separate registered from non-registered
  void _processContacts() {
    final List<ContactWithStatus> registeredContactsWithStatus = [];
    final List<ContactWithStatus> nonRegisteredContactsWithStatus = [];

    for (var contact in _phoneContacts) {
      if (contact.phones.isNotEmpty) {
        bool isRegistered = false;

        for (var phone in contact.phones) {
          final String cleanContactNumber = _cleanPhoneNumber(phone.number);

          for (var regPhone in _appRegisteredPhones) {
            final String cleanRegPhone = _cleanPhoneNumber(regPhone);

            log(
              'Contact: ${contact.displayName} | Number: $cleanContactNumber | Registered: $cleanRegPhone',
            );

            // Direct number match
            if (cleanContactNumber == cleanRegPhone) {
              isRegistered = true;
              log('MATCH FOUND: ${contact.displayName} is registered!');
              break;
            }

            // Special handling for Egyptian numbers with +20 prefix
            if (regPhone.startsWith('+20') &&
                cleanContactNumber.startsWith('0')) {
              // Compare without the leading 0 for local numbers
              final String contactWithoutLeadingZero = cleanContactNumber
                  .substring(1);
              final String regPhoneWithoutCountryCode =
                  cleanRegPhone.startsWith('20')
                      ? cleanRegPhone.substring(2)
                      : cleanRegPhone;

              if (contactWithoutLeadingZero == regPhoneWithoutCountryCode) {
                isRegistered = true;
                log(
                  'INTERNATIONAL FORMAT MATCH: ${contact.displayName} is registered!',
                );
                break;
              }
            }

            // Try comparing last 9 digits for partial match
            if (cleanContactNumber.length >= 10 && cleanRegPhone.length >= 10) {
              final String last9Contact = cleanContactNumber.substring(
                cleanContactNumber.length - 9,
              );
              final String last9RegPhone = cleanRegPhone.substring(
                cleanRegPhone.length - 9,
              );

              if (last9Contact == last9RegPhone) {
                isRegistered = true;
                log(
                  'PARTIAL MATCH FOUND: ${contact.displayName} is registered! (last 9 digits)',
                );
                break;
              }
            }
          }

          if (isRegistered) break;
        }

        final ContactWithStatus contactWithStatus = ContactWithStatus(
          contact: contact,
          isRegistered: isRegistered,
        );

        // Separate registered and non-registered contacts
        if (isRegistered) {
          registeredContactsWithStatus.add(contactWithStatus);
        } else {
          nonRegisteredContactsWithStatus.add(contactWithStatus);
        }
      }
    }

    // Group contacts by first letter
    _groupContactsByFirstLetter(
      registeredContactsWithStatus,
      _groupedRegisteredContacts,
    );
    _groupContactsByFirstLetter(
      nonRegisteredContactsWithStatus,
      _groupedNonRegisteredContacts,
    );
  }

  // Group contacts by first letter of display name
  void _groupContactsByFirstLetter(
    List<ContactWithStatus> contacts,
    Map<String, List<ContactWithStatus>> groupedMap,
  ) {
    groupedMap.clear();

    for (var contactWithStatus in contacts) {
      final contact = contactWithStatus.contact;
      if (contact.displayName.isNotEmpty) {
        // Use first letter of name as key
        final String firstLetter = contact.displayName[0].toUpperCase();

        if (!groupedMap.containsKey(firstLetter)) {
          groupedMap[firstLetter] = [];
        }

        groupedMap[firstLetter]!.add(contactWithStatus);
      }
    }

    // Sort keys alphabetically
    final sortedKeys = groupedMap.keys.toList()..sort();

    // Create a new map with sorted keys and sorted contacts within each key
    final Map<String, List<ContactWithStatus>> sortedGrouped = {};
    for (var key in sortedKeys) {
      groupedMap[key]!.sort(
        (a, b) => a.contact.displayName.compareTo(b.contact.displayName),
      );
      sortedGrouped[key] = groupedMap[key]!;
    }

    // Update the map
    groupedMap.clear();
    groupedMap.addAll(sortedGrouped);
  }

  /// Clean phone number for consistent matching
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

    log('Original: $phoneNumber | Cleaned: $cleanNumber');

    return cleanNumber;
  }

  // Filter registered contacts based on search query
  Map<String, List<ContactWithStatus>> _getFilteredRegisteredContacts() {
    if (_searchQuery.isEmpty) {
      return _groupedRegisteredContacts;
    }

    final filteredContacts = <String, List<ContactWithStatus>>{};

    _groupedRegisteredContacts.forEach((key, value) {
      final matches = value.where(
        (contactWithStatus) => contactWithStatus.contact.displayName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()),
      );

      if (matches.isNotEmpty) {
        filteredContacts[key] = matches.toList();
      }
    });

    return filteredContacts;
  }

  // Filter non-registered contacts based on search query
  Map<String, List<ContactWithStatus>> _getFilteredNonRegisteredContacts() {
    if (_searchQuery.isEmpty) {
      return _groupedNonRegisteredContacts;
    }

    final filteredContacts = <String, List<ContactWithStatus>>{};

    _groupedNonRegisteredContacts.forEach((key, value) {
      final matches = value.where(
        (contactWithStatus) => contactWithStatus.contact.displayName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()),
      );

      if (matches.isNotEmpty) {
        filteredContacts[key] = matches.toList();
      }
    });

    return filteredContacts;
  }

  // Send invitation to non-registered users
  Future<void> _sendInvitation(Contact contact) async {
    const String inviteText =
        'Join our app! You can download it from: https://mr_deffence.com/download';

    if (contact.phones.isNotEmpty) {
      await Share.share(inviteText, subject: 'Invitation to Join the App');
    }
  }

  /// Get the primary phone number from a contact
  String _getContactPhoneNumber(Contact contact) {
    if (contact.phones.isNotEmpty) {
      return contact.phones.first.number;
    }
    return 'No phone number';
  }

  /// Build contact avatar widget
  Widget _buildContactAvatar(Contact contact) {
    if (contact.photo != null && contact.photo!.isNotEmpty) {
      return CircleAvatar(backgroundImage: MemoryImage(contact.photo!));
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '?',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }
  }

  /// Create a formatted map to save contact to Firebase
  Map<String, dynamic> _createContactMap(Contact contact) {
    // Convert contact photo to base64 if available
    String? imageBase64;
    if (contact.photo != null && contact.photo!.isNotEmpty) {
      // In a real app, you'd convert to base64 or upload to storage
      // For simplicity, we'll leave this null for now
    }

    return {
      'id': contact.id,
      'name': contact.displayName,
      'phoneNumber': _getContactPhoneNumber(contact),
      'image': imageBase64,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  // Build a contact list tile
  Widget _buildContactTile(ContactWithStatus contactWithStatus) {
    final contact = contactWithStatus.contact;
    final isRegistered = contactWithStatus.isRegistered;
    final isSelected = _selectedContact?.contact.id == contact.id;

    return InkWell(
      onTap: () {
        if (isRegistered) {
          setState(() {
            _selectedContact = contactWithStatus;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFFFD5B68), width: 2)
                  : null,
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          leading: _buildContactAvatar(contact),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  contact.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  _getContactPhoneNumber(contact),
                  style: const TextStyle(color: Color(0xFF667085)),
                ),
              ),
              if (!isRegistered)
                ElevatedButton(
                  onPressed: () {
                    _sendInvitation(contact);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3C47),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text(
                    'Invite',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build UI sections for a group of contacts
  List<Widget> _buildContactSections(
    Map<String, List<ContactWithStatus>> contacts,
    String sectionTitle,
  ) {
    if (contacts.isEmpty) {
      return [];
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          sectionTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2E3C47),
          ),
        ),
      ),
      ...contacts.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            ...entry.value.map((contactWithStatus) {
              return _buildContactTile(contactWithStatus);
            }).toList(),
          ],
        );
      }).toList(),
    ];
  }

  /// Add selected contact to user's profile in Firebase
  Future<void> _addSelectedContactToProfile() async {
    if (_selectedContact == null || !_selectedContact!.isRegistered) {
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        showPopUpAlert(
          context: context,
          message: 'User not authenticated',
          icon: Icons.error,
          color: kError,
        );
        return;
      }

      // Prepare contact data
      final contactData = _createContactMap(_selectedContact!.contact);

      //------------------------------------------------------------------------------------------------------------
      // Add contact to user's contacts subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(_selectedContact!.contact.id)
          .set(contactData);

      // Return the contact data to update UI immediately
      GoRouter.of(context).pop(_selectedContact!.contact);
      showPopUpAlert(
        context: context,
        message: 'Contact added successfully',
        icon: Icons.check_circle,
        color: kSuccess,
      );
    } catch (e) {
      log('Error adding contact to profile: $e');
      showPopUpAlert(
        context: context,
        message: 'Error adding contact to profile',
        icon: Icons.error,
        color: kError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRegisteredContacts = _getFilteredRegisteredContacts();
    final filteredNonRegisteredContacts = _getFilteredNonRegisteredContacts();

    final bool hasRegisteredContacts = filteredRegisteredContacts.isNotEmpty;
    final bool hasNonRegisteredContacts =
        filteredNonRegisteredContacts.isNotEmpty;
    final bool hasContacts = hasRegisteredContacts || hasNonRegisteredContacts;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              // Search bar and back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).pop();
                      },
                      child: Image.asset(
                        'assets/profile_assets/images/BackIcon.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search ...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 44,
                              width: 87,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E3C47),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(32),
                                  bottomRight: Radius.circular(32),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Color(0xFFABB7C2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contact lists
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : !hasContacts
                        ? const Center(child: Text('No contacts found'))
                        : ListView(
                          children: [
                            // Registered Contacts Section
                            ..._buildContactSections(
                              filteredRegisteredContacts,
                              'Registered Contacts',
                            ),

                            // Non-Registered Contacts Section
                            ..._buildContactSections(
                              filteredNonRegisteredContacts,
                              'Other Contacts',
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _selectedContact != null && _selectedContact!.isRegistered
              ? FloatingActionButton(
                onPressed: () => _addSelectedContactToProfile(),
                backgroundColor: const Color(0xFFFD5B68),
                child: const Icon(Icons.check, color: Colors.white),
              )
              : null,
    );
  }
}
