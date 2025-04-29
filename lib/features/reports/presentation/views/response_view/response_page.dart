import 'package:app/core/utils/helper.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
import 'package:app/features/reports/presentation/manager/response_cubit/response_cubit.dart';
import 'package:app/features/reports/presentation/views/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/reports/data/models/report.dart';

class EmergencyRequestDetailsView extends StatefulWidget {
  final Report report;

  const EmergencyRequestDetailsView({Key? key, required this.report})
    : super(key: key);

  @override
  State<EmergencyRequestDetailsView> createState() =>
      _EmergencyRequestDetailsViewState();
}

class _EmergencyRequestDetailsViewState
    extends State<EmergencyRequestDetailsView> {
  late EmergencyRequestCubit _cubit;
  late bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  EmergencyType? _emergencyType;

  @override
  void initState() {
    super.initState();
    _cubit = EmergencyRequestCubit();
    _loadUserData();
    _loadEmergencyType();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _cubit.getUserData(widget.report.userId);
      setState(() {
        _userData = userData;
        _isLoadingUserData = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  void _loadEmergencyType() {
    if (widget.report.emergencyType.isNotEmpty) {
      setState(() {
        _emergencyType = theWholeEmergencies.firstWhere(
          (type) =>
              type.name.toLowerCase() ==
              widget.report.emergencyType.toLowerCase(),
          orElse:
              () => EmergencyType(
                name: widget.report.emergencyType,
                iconPath: AssetsData.fire,
                backgroundColor: Colors.red,
              ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSOS = widget.report.requestType.toLowerCase() == 'sos';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isSOS ? 'SOS Alert' : 'Emergency Alert',
          style: Styles.textStyle20(context).copyWith(color: kGradientColor1),
        ),
        centerTitle: true,
      ),
      body:
          _isLoadingUserData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoSection(context),
                      const SizedBox(height: 16),
                      if (!isSOS) _buildAdditionalInfo(),
                      const SizedBox(height: 16),
                      _buildMediaSection(isSOS),
                      const SizedBox(height: 16),
                      if (widget.report.videos.isNotEmpty) _buildVideoSection(),
                      const SizedBox(height: 24),
                      if (widget.report.status.toLowerCase() == 'open' ||
                          widget.report.status.toLowerCase() == 'pending')
                        if (widget.report.userId != _cubit.getCurrentUserId() &&
                            widget.report.status.toLowerCase() != 'closed')
                          _buildAcceptanceButtons(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    final bool isSOS = widget.report.requestType.toLowerCase() == 'sos';
    final String userName = _userData?['firstName'] ?? 'Unknown';
    final String userFullName =
        '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}';
    final String userPhoneNumber = _userData?['phoneNumber'] ?? '';
    final bool whoNeedsHelp = widget.report.whoHappened;
    final photoUrl = _userData!['profilePicture'];
    final hasValidPhoto = photoUrl != null && photoUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            hasValidPhoto
                ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: Colors.grey[300],
                )
                : SvgPicture.asset(
                  AssetsData.avatar,
                  fit: BoxFit.cover,
                  width: Helper.getResponsiveWidth(context, width: 69),
                  height: Helper.getResponsiveHeight(context, height: 69),
                ),

            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName.isNotEmpty
                      ? userFullName.trim()
                      : 'Unknown User',
                  style: Styles.textStyle18(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                if (userPhoneNumber.isNotEmpty)
                  Text(
                    userPhoneNumber,
                    style: Styles.textStyle14(
                      context,
                    ).copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isSOS)
          Text(
            '$userName needs urgent help!',
            style: Styles.textStyle16(
              context,
            ).copyWith(color: kError, fontWeight: FontWeight.bold),
          )
        else if (whoNeedsHelp)
          Text(
            '$userName needs urgent help!',
            style: Styles.textStyle16(
              context,
            ).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        _buildInfoCard(context),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final DateTime occurredTime = widget.report.occuredTime;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(occurredTime);
    final formattedTime = DateFormat('h:mm a').format(occurredTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffCECECE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: Helper.getResponsiveWidth(context, width: 9),
                  ),
                  child: _buildInfoItem(
                    context,
                    icon: Icons.warning_amber_outlined,
                    title: 'Emergency Type',
                    value: _emergencyType?.name ?? widget.report.emergencyType,
                    iconColor: _emergencyType?.backgroundColor ?? Colors.orange,
                  ),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Who needs help?',
                  value:
                      widget.report.whoHappened
                          ? _userData!['firstName'] ?? 'Unknown'
                          : 'Other person',
                  iconColor: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: widget.report.locationName,
                  iconColor: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Date & Time',
                  value: '$formattedDate\n$formattedTime',
                  iconColor: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _showUserDetailsDialog(context),
            child: Text(
              'Know more',
              style: Styles.textStyle14(
                context,
              ).copyWith(color: kError, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: Helper.getResponsiveWidth(context, width: 45),
          height: Helper.getResponsiveWidth(context, width: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        SizedBox(width: Helper.getResponsiveHeight(context, height: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Styles.textStyle12(context).copyWith(
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 12),
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Styles.textStyle14(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Helper.getResponsiveFontSize(context, fontSize: 12),
                  color: const Color.fromARGB(255, 125, 125, 125),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xffCECECE),
            title: const Text('User Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildUserDetailItem(
                    'Name',
                    '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}',
                  ),
                  _buildUserDetailItem(
                    'Email',
                    _userData?['email'] ?? 'Not available',
                  ),
                  _buildUserDetailItem(
                    'Phone',
                    _userData?['phoneNumber'] ?? 'Not available',
                  ),
                  _buildUserDetailItem(
                    'Gender',
                    _userData?['gender'] ?? 'Not available',
                  ),
                  _buildUserDetailItem(
                    'Nationality',
                    _userData?['nationality'] ?? 'Not available',
                  ),
                  _buildUserDetailItem(
                    'Language',
                    _userData?['language'] ?? 'Not available',
                  ),
                  if (_userData?['hasMedicalCondition'] == true)
                    _buildUserDetailItem('Medical Condition', 'Yes'),
                  if (_userData?['isdiabetic'] == true)
                    _buildUserDetailItem('Diabetic', 'Yes'),
                  if (_userData?['usesWheelchair'] == true)
                    _buildUserDetailItem('Uses Wheelchair', 'Yes'),
                  if (_userData?['height'] != null)
                    _buildUserDetailItem('Height', _userData?['height']),
                  if (_userData?['weight'] != null)
                    _buildUserDetailItem('Weight', _userData?['weight']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildUserDetailItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    if (widget.report.description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Info',
          style: Styles.textStyle16(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.report.description,
            style: Styles.textStyle14(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection(bool isSOS) {
    final bool hasImages = widget.report.pictures.isNotEmpty;
    if (!hasImages) return const SizedBox.shrink();

    final String title =
        isSOS ? 'Auto Footage/Picture' : 'Live Footage/Picture';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.textStyle16(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (isSOS) _buildSOSImageGrid() else _buildAlertImageGrid(),
      ],
    );
  }

  Widget _buildSOSImageGrid() {
    final images = widget.report.pictures;
    if (images.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < images.length && i < 2; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 0 ? 8.0 : 0),
              child: GestureDetector(
                onTap: () => _showFullScreenImage(images[i]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[i],
                    height: 186,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 186,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 186,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertImageGrid() {
    final images = widget.report.pictures;
    if (images.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        // First image (large)
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _showFullScreenImage(images[0]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[0],
                height: 186,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 186,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 186,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Column with two smaller images
        if (images.length > 1)
          Expanded(
            child: Column(
              children: [
                if (images.length > 1)
                  GestureDetector(
                    onTap: () => _showFullScreenImage(images[1]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[1],
                        height: 111,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 111,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 111,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (images.length > 2)
                  GestureDetector(
                    onTap: () => _showFullScreenImage(images[2]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[2],
                        height: 93,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 93,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 93,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildVideoSection() {
    final videos = widget.report.videos;
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live stream',
          style: Styles.textStyle16(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _showFullScreenVideo(videos[0]),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[800],
                    child: Image.network(
                      // Use a thumbnail if available, otherwise use a placeholder
                      videos.length > 1 ? videos[1] : AssetsData.videoIcon,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenVideo(String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  Widget _buildAcceptanceButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Do you want to accept this Emergency?',
          style: Styles.textStyle16(
            context,
          ).copyWith(color: kError, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleEmergencyResponse(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('No'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleEmergencyResponse(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary500n800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleEmergencyResponse(bool accept) async {
    try {
      final String currentUserId = _cubit.getCurrentUserId();
      final String reportId = widget.report.id;

      if (accept) {
        // Add user to receiver_guardians
        await _cubit.acceptEmergencyRequest(reportId, currentUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency accepted. You are now a guardian.'),
          ),
        );
      } else {
        // Remove user from receiver_guardians if they are already in it
        await _cubit.declineEmergencyRequest(reportId, currentUserId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Emergency declined.')));
      }

      Navigator.of(context).pop(true); // Return true to indicate a change
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
