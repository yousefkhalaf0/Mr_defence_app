import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  final Map<String, List<Map<String, String>>> allContacts = {
    'A': [
      {
        'name': 'Alexander',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=1',
      },
      {
        'name': 'August Hilton',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=2',
      },
    ],
    'J': [
      {
        'name': 'Josh Eigner',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=3',
      },
    ],
    'N': [
      {
        'name': 'Noelle Norman',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=4',
      },
      {
        'name': 'Nicolas Huge',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=5',
      },
    ],
    'V': [
      {
        'name': 'Viona Scylla',
        'phone': '+20 1219283723',
        'image': 'https://i.pravatar.cc/100?img=6',
      },
    ],
  };

  String searchQuery = '';
  String? selectedContactName;

  @override
  Widget build(BuildContext context) {
    final filteredContacts = <String, List<Map<String, String>>>{};

    allContacts.forEach((key, value) {
      final matches = value.where(
        (contact) =>
            contact['name']!.toLowerCase().contains(searchQuery.toLowerCase()),
      );
      if (matches.isNotEmpty) {
        filteredContacts[key] = matches.toList();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
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
                child: ListView(
                  children:
                      filteredContacts.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            ...entry.value.map((contact) {
                              final isSelected =
                                  selectedContactName == contact['name'];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedContactName = contact['name'];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: const Color(0xFFFD5B68),
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.transparent,
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        contact['image']!,
                                      ),
                                    ),
                                    title: Text(
                                      contact['name']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      contact['phone']!,
                                      style: const TextStyle(
                                        color: Color(0xFF667085),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedContactName != null) {
            final selectedContact = allContacts.values
                .expand((list) => list)
                .firstWhere(
                  (contact) => contact['name'] == selectedContactName,
                );
            Navigator.pop(context, selectedContact);
          }
        },
        backgroundColor: const Color(0xFFFD5B68),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
