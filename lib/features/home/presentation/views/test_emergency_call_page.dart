import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/home/presentation/manager/emergency_call_cubit/emergency_call_cubit.dart';
import 'package:app/features/home/presentation/manager/sos_request_cubit/sos_request_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmergencyCallingPage extends StatelessWidget {
  final EmergencyType emergencyType;
  final String frontPhotoPath;
  final String backPhotoPath;
  final String audioPath;
  final String requestType;

  const EmergencyCallingPage({
    super.key,
    required this.emergencyType,
    required this.frontPhotoPath,
    required this.backPhotoPath,
    required this.requestType,
    required this.audioPath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => EmergencyCallCubit(
            requestCubit: context.read<RequestCubit>(),
            timeoutDuration: const Duration(minutes: 5),
          )..initializeEmergencyCall(
            emergencyType: emergencyType,
            frontPhotoPath: frontPhotoPath,
            backPhotoPath: backPhotoPath,
            audioPath: audioPath,
            requestType: requestType,
          ),
      child: _EmergencyCallingContent(),
    );
  }
}

class _EmergencyCallingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          title: const Text(
            'Emergency Call',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<EmergencyCallCubit, EmergencyCallState>(
          listener: (context, state) {
            // Handle navigation or dialogs based on state
            if (state.status == EmergencyCallStatus.expired &&
                !state.isHandled) {
              context.read<EmergencyCallCubit>().markAsHandled();
              _showExpirationDialog(context);
            } else if (state.status == EmergencyCallStatus.accepted) {
              _showAcceptedDialog(
                context,
                state.acceptedByGuardian ?? 'Someone',
              );
            } else if (state.status == EmergencyCallStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == EmergencyCallStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Status bar with timer
                _buildStatusBar(context, state),

                // Media preview section
                if (state.frontPhotoUrl != null)
                  _buildMediaPreview(context, state),

                // Contacts section
                Expanded(child: _buildContactsList(context, state)),

                // Bottom actions
                _buildBottomActions(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, EmergencyCallState state) {
    final String statusText;
    final Color statusColor;

    switch (state.status) {
      case EmergencyCallStatus.created:
        statusText = 'Alerting emergency contacts...';
        statusColor = Colors.orange;
        break;
      case EmergencyCallStatus.accepted:
        statusText = 'Accepted by ${state.acceptedByGuardian}';
        statusColor = Colors.green;
        break;
      case EmergencyCallStatus.expired:
        statusText = 'No response from contacts';
        statusColor = Colors.red;
        break;
      case EmergencyCallStatus.cancelled:
        statusText = 'Emergency cancelled';
        statusColor = Colors.grey;
        break;
      default:
        statusText = 'Connecting...';
        statusColor = Colors.blue;
    }

    return Container(
      color: statusColor.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            state.status == EmergencyCallStatus.accepted
                ? Icons.check_circle
                : Icons.warning,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          if (state.status == EmergencyCallStatus.created)
            Text(
              context.read<EmergencyCallCubit>().formattedTime,
              style: TextStyle(
                color:
                    state.secondsRemaining < 60 ? Colors.red : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context, EmergencyCallState state) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (state.frontPhotoUrl != null && state.frontPhotoUrl!.isNotEmpty)
            _buildMediaThumbnail(state.frontPhotoUrl!, 'Front Photo'),
          if (state.backPhotoUrl != null && state.backPhotoUrl!.isNotEmpty)
            _buildMediaThumbnail(state.backPhotoUrl!, 'Back Photo'),
          if (state.audioUrl != null && state.audioUrl!.isNotEmpty)
            _buildAudioThumbnail(state.audioUrl!, 'Audio Recording'),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail(String url, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAudioThumbnail(String url, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.mic, color: Colors.blue)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, EmergencyCallState state) {
    if (state.emergencyContacts.isEmpty) {
      return const Center(child: Text('No emergency contacts available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.emergencyContacts.length,
      itemBuilder: (context, index) {
        final contact = state.emergencyContacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(contact.image),
              radius: 24,
            ),
            title: Text(contact.name),
            subtitle: Text(
              state.status == EmergencyCallStatus.accepted &&
                      state.acceptedByGuardian == contact.name
                  ? 'Accepted your emergency call'
                  : 'Notified about your emergency',
              style: TextStyle(
                color:
                    state.status == EmergencyCallStatus.accepted &&
                            state.acceptedByGuardian == contact.name
                        ? Colors.green
                        : Colors.grey[600],
              ),
            ),
            trailing:
                state.status == EmergencyCallStatus.accepted &&
                        state.acceptedByGuardian == contact.name
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : state.status == EmergencyCallStatus.expired
                    ? const Icon(Icons.hourglass_empty, color: Colors.grey)
                    : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context, EmergencyCallState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  state.status == EmergencyCallStatus.cancelled ||
                          state.status == EmergencyCallStatus.expired
                      ? null
                      : () =>
                          context.read<EmergencyCallCubit>().cancelEmergency(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel Emergency'),
            ),
          ),
          if (state.status == EmergencyCallStatus.expired ||
              state.status == EmergencyCallStatus.accepted)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home or emergency tracking page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Go Home'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExpirationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('No Response'),
            content: const Text(
              'None of your emergency contacts responded. Would you like to try again or call emergency services?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go Home'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add direct emergency services call
                  // launchUrl(Uri.parse('tel:911'));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Call Emergency Services'),
              ),
            ],
          ),
    );
  }

  void _showAcceptedDialog(BuildContext context, String guardianName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('$guardianName Accepted'),
            content: Text(
              '$guardianName has accepted your emergency call and will be contacting you shortly.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
