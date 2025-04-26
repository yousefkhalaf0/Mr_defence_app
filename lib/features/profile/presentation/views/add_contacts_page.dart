// ignore_for_file: prefer_const_constructors, unnecessary_to_list_in_spreads, avoid_print

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  // Store contacts data
  Map<String, List<ContactWithStatus>> groupedRegisteredContacts = {};
  Map<String, List<ContactWithStatus>> groupedNonRegisteredContacts = {};
  List<Contact> phoneContacts = [];
  List<String> appRegisteredPhones = [];
  bool isLoading = true;
  String searchQuery = '';
  ContactWithStatus? selectedContact;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // First fetch registered users from Firebase
    await _fetchRegisteredUsers();
    // Then fetch phone contacts and compare them
    await _fetchContacts();
  }

  // Fetch registered users from Firestore
  Future<void> _fetchRegisteredUsers() async {
    try {
      // Get users list from Firestore
      final usersSnapshot = await _firestore.collection('users').get();
      
      List<String> phones = [];
      print('--- Registered Phone Numbers from Firebase ---');
      for (var doc in usersSnapshot.docs) {
        // Check if phoneNumber exists and is not empty
        if (doc.data().containsKey('phoneNumber')) {
          String phone = doc.data()['phoneNumber'] as String? ?? '';
          if (phone.isNotEmpty) {
            print('Firebase phone number (original): $phone');
            print('Firebase phone number (cleaned): ${_cleanPhoneNumber(phone)}');
            phones.add(phone);
          }
        }
      }
      
      setState(() {
        appRegisteredPhones = phones;
      });
    } catch (e) {
      print('Error fetching registered users: $e');
      // If error occurs, assume no registered users
      appRegisteredPhones = [];
    }
  }

  // Fetch contacts from device
  Future<void> _fetchContacts() async {
    // Request contacts permission
    var status = await Permission.contacts.request();
    
    if (status.isGranted) {
      try {
        // Permission granted, fetch contacts
        final fetchedContacts = await FlutterContacts.getContacts(
          withPhoto: true,
          withProperties: true,
        );
        
        setState(() {
          phoneContacts = fetchedContacts;
          _processContacts();
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching contacts: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      // Show error message when permission is denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need to allow contacts access to use this feature'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Process contacts and compare with registered users
  void _processContacts() {
    List<ContactWithStatus> registeredContactsWithStatus = [];
    List<ContactWithStatus> nonRegisteredContactsWithStatus = [];
    
    for (var contact in phoneContacts) {
      if (contact.phones.isNotEmpty) {
        bool isRegistered = false;
        
        for (var phone in contact.phones) {
          String cleanContactNumber = _cleanPhoneNumber(phone.number);
          
          for (var regPhone in appRegisteredPhones) {
            String cleanRegPhone = _cleanPhoneNumber(regPhone);
            
            // Print for debugging
            print('Contact: ${contact.displayName} | Number: $cleanContactNumber | Registered: $cleanRegPhone');
            
            // Compare cleaned numbers
            if (cleanContactNumber == cleanRegPhone) {
              isRegistered = true;
              print('MATCH FOUND: ${contact.displayName} is registered!');
              break;
            }
            
            // Special handling for Egyptian numbers with +20 prefix
            if (regPhone.startsWith('+20') && cleanContactNumber.startsWith('0')) {
              // Compare without the leading 0 for local numbers
              String contactWithoutLeadingZero = cleanContactNumber.substring(1);
              String regPhoneWithoutCountryCode = cleanRegPhone.startsWith('20') 
                  ? cleanRegPhone.substring(2) 
                  : cleanRegPhone;
                  
              if (contactWithoutLeadingZero == regPhoneWithoutCountryCode) {
                isRegistered = true;
                print('INTERNATIONAL FORMAT MATCH: ${contact.displayName} is registered!');
                break;
              }
            }
            
            // Try comparing last 9 digits (without leading zero)
            if (cleanContactNumber.length >= 10 && cleanRegPhone.length >= 10) {
              String last9Contact = cleanContactNumber.substring(cleanContactNumber.length - 9);
              String last9RegPhone = cleanRegPhone.substring(cleanRegPhone.length - 9);
              
              if (last9Contact == last9RegPhone) {
                isRegistered = true;
                print('PARTIAL MATCH FOUND: ${contact.displayName} is registered! (last 9 digits)');
                break;
              }
            }
          }
          
          if (isRegistered) break;
        }
        
        ContactWithStatus contactWithStatus = ContactWithStatus(
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
    
    // Group contacts separately for registered and non-registered
    _groupRegisteredContacts(registeredContactsWithStatus);
    _groupNonRegisteredContacts(nonRegisteredContactsWithStatus);
  }

  // Improved phone number cleaning function for international numbers
  String _cleanPhoneNumber(String phoneNumber) {
    // Trim spaces and clean up
    String cleanNumber = phoneNumber.trim();
    
    // Handle Egyptian numbers with +20 prefix
    if (cleanNumber.startsWith('+')) {
      // If the number starts with +, remove it
      cleanNumber = cleanNumber.substring(1);
    }
    
    // Remove all non-digit characters
    cleanNumber = cleanNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Special handling for Egyptian numbers - if starts with country code 20
    if (cleanNumber.startsWith('20') && cleanNumber.length > 10) {
      // If the number contains country code 20, we'll keep both versions
      // for better matching (with and without country code)
      return cleanNumber;
    }
    
    // Handle 002 prefix (another format for Egypt)
    if (cleanNumber.startsWith('002') && cleanNumber.length > 11) {
      cleanNumber = cleanNumber.substring(3);
    }
    
    // Print for debugging
    print('Original: $phoneNumber | Cleaned: $cleanNumber');
    
    return cleanNumber;
  }

  // Group registered contacts by first letter
  void _groupRegisteredContacts(List<ContactWithStatus> contacts) {
    Map<String, List<ContactWithStatus>> grouped = {};
    
    for (var contactWithStatus in contacts) {
      var contact = contactWithStatus.contact;
      if (contact.displayName.isNotEmpty) {
        // Use first letter of name as key
        String firstLetter = contact.displayName[0].toUpperCase();
        
        if (!grouped.containsKey(firstLetter)) {
          grouped[firstLetter] = [];
        }
        
        grouped[firstLetter]!.add(contactWithStatus);
      }
    }
    
    // Sort keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    
    Map<String, List<ContactWithStatus>> sortedGrouped = {};
    for (var key in sortedKeys) {
      // Sort contacts within each group alphabetically
      grouped[key]!.sort((a, b) => 
          a.contact.displayName.compareTo(b.contact.displayName));
      sortedGrouped[key] = grouped[key]!;
    }
    
    groupedRegisteredContacts = sortedGrouped;
  }
  
  // Group non-registered contacts by first letter
  void _groupNonRegisteredContacts(List<ContactWithStatus> contacts) {
    Map<String, List<ContactWithStatus>> grouped = {};
    
    for (var contactWithStatus in contacts) {
      var contact = contactWithStatus.contact;
      if (contact.displayName.isNotEmpty) {
        // Use first letter of name as key
        String firstLetter = contact.displayName[0].toUpperCase();
        
        if (!grouped.containsKey(firstLetter)) {
          grouped[firstLetter] = [];
        }
        
        grouped[firstLetter]!.add(contactWithStatus);
      }
    }
    
    // Sort keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    
    Map<String, List<ContactWithStatus>> sortedGrouped = {};
    for (var key in sortedKeys) {
      // Sort contacts within each group alphabetically
      grouped[key]!.sort((a, b) => 
          a.contact.displayName.compareTo(b.contact.displayName));
      sortedGrouped[key] = grouped[key]!;
    }
    
    groupedNonRegisteredContacts = sortedGrouped;
  }

  // Filter contacts based on search query
  Map<String, List<ContactWithStatus>> _getFilteredRegisteredContacts() {
    if (searchQuery.isEmpty) {
      return groupedRegisteredContacts;
    }
    
    final filteredContacts = <String, List<ContactWithStatus>>{};
    
    groupedRegisteredContacts.forEach((key, value) {
      final matches = value.where((contactWithStatus) =>
          contactWithStatus.contact.displayName.toLowerCase().contains(searchQuery.toLowerCase()));
      
      if (matches.isNotEmpty) {
        filteredContacts[key] = matches.toList();
      }
    });
    
    return filteredContacts;
  }
  
  // Filter non-registered contacts based on search query
  Map<String, List<ContactWithStatus>> _getFilteredNonRegisteredContacts() {
    if (searchQuery.isEmpty) {
      return groupedNonRegisteredContacts;
    }
    
    final filteredContacts = <String, List<ContactWithStatus>>{};
    
    groupedNonRegisteredContacts.forEach((key, value) {
      final matches = value.where((contactWithStatus) =>
          contactWithStatus.contact.displayName.toLowerCase().contains(searchQuery.toLowerCase()));
      
      if (matches.isNotEmpty) {
        filteredContacts[key] = matches.toList();
      }
    });
    
    return filteredContacts;
  }

  // Send invitation to non-registered users
  void _sendInvitation(Contact contact) async {
    final String inviteText = 'Join our app! You can download it from: https://mr_deffence.com/download';
    
    // Use share_plus package to send invitation message
    if (contact.phones.isNotEmpty) {
      final String phoneNumber = contact.phones.first.number;
      await Share.share(inviteText, subject: 'Invitation to Join the App');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRegisteredContacts = _getFilteredRegisteredContacts();
    final filteredNonRegisteredContacts = _getFilteredNonRegisteredContacts();
    
    // Determine if we have any contacts to display
    final bool hasRegisteredContacts = filteredRegisteredContacts.isNotEmpty;
    final bool hasNonRegisteredContacts = filteredNonRegisteredContacts.isNotEmpty;
    final bool hasContacts = hasRegisteredContacts || hasNonRegisteredContacts;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                                      searchQuery = value;
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
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !hasContacts
                        ? const Center(child: Text('No contacts found'))
                        : ListView(
                            children: [
                              // Registered Contacts Section
                              if (hasRegisteredContacts) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Text(
                                    'Registered Contacts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF2E3C47),
                                    ),
                                  ),
                                ),
                                ...filteredRegisteredContacts.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
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
                              ],
                              
                              // Non-Registered Contacts Section
                              if (hasNonRegisteredContacts) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Text(
                                    'Other Contacts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF2E3C47),
                                    ),
                                  ),
                                ),
                                ...filteredNonRegisteredContacts.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
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
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedContact != null && selectedContact!.isRegistered
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, selectedContact!.contact);
              },
              backgroundColor: const Color(0xFFFD5B68),
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }

  // Extract contact tile building to a separate method
  Widget _buildContactTile(ContactWithStatus contactWithStatus) {
    final contact = contactWithStatus.contact;
    final isRegistered = contactWithStatus.isRegistered;
    final isSelected = selectedContact?.contact.id == contact.id;

    return InkWell(
      onTap: () {
        if (isRegistered) {
          setState(() {
            selectedContact = contactWithStatus;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFFD5B68), width: 2)
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isRegistered)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Registered',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  _getContactPhoneNumber(contact),
                  style: const TextStyle(
                    color: Color(0xFF667085),
                  ),
                ),
              ),
              if (!isRegistered)
                ElevatedButton(
                  onPressed: () => _sendInvitation(contact),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3C47),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size(0, 30),
                  ),
                  child: Text(
                    'Invite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build contact avatar widget
  Widget _buildContactAvatar(Contact contact) {
    if (contact.photo != null && contact.photo!.isNotEmpty) {
      // Use stored image if available
      return CircleAvatar(
        backgroundImage: MemoryImage(contact.photo!),
      );
    } else {
      // Use first letter as default avatar
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }
  }

  // Get phone number from contact
  String _getContactPhoneNumber(Contact contact) {
    if (contact.phones.isNotEmpty) {
      return contact.phones.first.number;
    }
    return 'No phone number';
  }
}

// Additional class to track contact status (registered or not)
class ContactWithStatus {
  final Contact contact;
  final bool isRegistered;

  ContactWithStatus({
    required this.contact,
    required this.isRegistered,
  });
}