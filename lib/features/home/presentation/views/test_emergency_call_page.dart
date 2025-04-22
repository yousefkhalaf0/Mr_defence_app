import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:app/features/home/presentation/manager/sos_request_cubit/sos_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/home/data/request_data.dart';
import 'package:go_router/go_router.dart';

// Import your cubit

class EmergencyCallingPage extends StatefulWidget {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;
  final String audioPath;

  // This allows you to configure the timer duration
  final Duration timeoutDuration;

  const EmergencyCallingPage({
    Key? key,
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
    required this.audioPath,
    // Default to 30 seconds for testing, change to 5 minutes for production
    this.timeoutDuration = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<EmergencyCallingPage> createState() => _EmergencyCallingPageState();
}

class _EmergencyCallingPageState extends State<EmergencyCallingPage> {
  int _secondsElapsed = 0;
  int _secondsRemaining = 0;
  late Timer _timer;
  bool _isProcessing = true;
  String? _errorMessage;
  SOSRequest? _createdRequest;
  String? _acceptedByGuardian;
  bool _isExpired = false;

  // Mock emergency contacts - in a real app, these would come from a database
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: "Amy Jackson",
      image: "assets/images/contacts/amy.jpg",
    ),
    EmergencyContact(
      name: "Sister",
      image: "assets/images/contacts/sister.jpg",
    ),
    EmergencyContact(name: "Dad", image: "assets/images/contacts/dad.jpg"),
    EmergencyContact(
      name: "Albert",
      image: "assets/images/contacts/albert.jpg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the remaining seconds from the timeout duration
    _secondsRemaining = widget.timeoutDuration.inSeconds;
    _startTimer();
    _processEmergencyRequest();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _secondsRemaining--;

        // Auto-cancel when time runs out
        if (_secondsRemaining <= 0 && !_isExpired) {
          _isExpired = true;
          _handleExpiration();
        }
      });
    });
  }

  void _handleExpiration() {
    _timer.cancel();
    // Show expiration dialog and redirect
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Emergency Request Expired"),
            content: const Text(
              "Your emergency request has timed out. No guardians have responded within the allotted time. Would you like to try again or return home?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Return to home page
                  context.go('/homeView');
                },
                child: const Text("Return Home"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Restart the process (go to first emergency page)
                  context.go('/homeView'); // Then navigate to emergency flow
                },
                child: const Text("Try Again"),
              ),
            ],
          ),
    );
  }

  Future<void> _processEmergencyRequest() async {
    // Process the emergency request using the cubit
    final requestCubit = context.read<RequestCubit>();

    // Process the SOS request with the captured data
    await requestCubit.processSosRequest(
      widget.emergencyType,
      widget.frontPhotoPath,
      widget.backPhotoPath,
      widget.audioPath,
    );
  }

  String get _formattedTime {
    // Shows remaining time instead of elapsed time
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:00";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestCubit, RequestState>(
      listener: (context, state) {
        if (state is RequestCreated) {
          setState(() {
            _isProcessing = false;
            _createdRequest = state.request;
          });
        } else if (state is RequestAccepted) {
          setState(() {
            _acceptedByGuardian = state.guardianId;
            // Find the corresponding contact name if possible
            final contactIndex = _emergencyContacts.indexWhere(
              (contact) => contact.id == state.guardianId,
            );
            if (contactIndex != -1) {
              _acceptedByGuardian = _emergencyContacts[contactIndex].name;
            }

            // Cancel the expiration timer when someone accepts
            _isExpired = true;
          });

          // Show a notification that someone accepted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${_acceptedByGuardian} is coming to help you!"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is RequestExpired) {
          if (!_isExpired) {
            setState(() {
              _isExpired = true;
            });
            _handleExpiration();
          }
        } else if (state is RequestError) {
          setState(() {
            _errorMessage = state.message;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade300, Colors.grey.shade200],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Emergency title
                Text(
                  _acceptedByGuardian != null
                      ? "$_acceptedByGuardian is coming..."
                      : "Calling emergency...",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3B55),
                  ),
                ),
                const SizedBox(height: 10),
                // Status message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _acceptedByGuardian != null
                        ? "Help is on the way. $_acceptedByGuardian has accepted your emergency request and is coming to assist you."
                        : "Please stand by, we are currently requesting for help. Your emergency contacts and nearby rescue services would see your call for help",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 40),
                // Timer and contacts visualization
                Expanded(
                  child: BlocBuilder<RequestCubit, RequestState>(
                    builder: (context, state) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular gradient background
                          Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.pink.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.2),
                                ],
                                stops: const [0.3, 0.8],
                              ),
                            ),
                          ),
                          // Dashed circles - 3 circles for better visualization
                          ...List.generate(
                            3,
                            (index) => Container(
                              width: 180 + (index * 70),
                              height: 180 + (index * 70),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                          // Timer circle
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _acceptedByGuardian != null
                                          ? Colors.green
                                          : (_secondsRemaining < 30
                                              ? Colors.orange
                                              : Colors.red),
                                ),
                                child: Center(
                                  child: Text(
                                    _formattedTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Emergency contacts positioned around the timer
                          ..._positionContacts(),

                          // Show loading indicator when processing
                          if (state is RequestLoading)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Cancel button at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    onPressed: _cancelEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Cancel Emergency",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _cancelEmergency() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Cancel Emergency?"),
            content: const Text(
              "Are you sure you want to cancel this emergency request? This will notify your emergency contacts that you are safe.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("No, continue"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performCancellation();
                },
                child: const Text(
                  "Yes, cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _performCancellation() {
    // Here you would implement cancellation logic for the Firestore document
    // For example:
    // FirebaseFirestore.instance
    //    .collection('emergency_requests')
    //    .doc(_createdRequest?.id)
    //    .update({'status': 'cancelled'});

    // Navigate back to the home page
    context.go('/homeView');
  }

  List<Widget> _positionContacts() {
    List<Widget> contactWidgets = [];
    final double radius = 160.0;

    for (int i = 0; i < _emergencyContacts.length; i++) {
      final contact = _emergencyContacts[i];
      // Calculate position along the circle
      double angle = (i * 2 * pi) / _emergencyContacts.length;
      // Adjust starting position to match the image
      angle += pi / 4; // 45 degrees

      final dx = radius * cos(angle);
      final dy = radius * sin(angle);

      // Special handling for contacts who have accepted the request
      bool isAccepted = false;
      if (_acceptedByGuardian != null &&
          (_acceptedByGuardian == contact.name ||
              _acceptedByGuardian == contact.id)) {
        isAccepted = true;
      }

      contactWidgets.add(
        Positioned(
          left: MediaQuery.of(context).size.width / 2 + dx - 25,
          top: 320 / 2 + dy - 25,
          child: Column(
            children: [
              Container(
                decoration:
                    isAccepted
                        ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                        : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade400,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade600,
                      backgroundImage: AssetImage(contact.image),
                      onBackgroundImageError: (_, __) {
                        // If image fails to load, the CircleAvatar will show the fallback
                      },
                      child: Text(
                        contact.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.name.split(' ')[0],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  fontWeight: isAccepted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return contactWidgets;
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String image;

  EmergencyContact({String? id, required this.name, required this.image})
    : id = id ?? name.toLowerCase().replaceAll(' ', '_');
}
