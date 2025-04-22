import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';

class AutoCapturePage extends StatefulWidget {
  final CameraLensDirection cameraDirection;
  final EmergencyType emergencyType;
  final String? frontPhotoPath;

  const AutoCapturePage({
    Key? key,
    required this.cameraDirection,
    required this.emergencyType,
    this.frontPhotoPath,
  }) : super(key: key);

  @override
  State<AutoCapturePage> createState() => _AutoCapturePageState();
}

class _AutoCapturePageState extends State<AutoCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isControllerInitialized = false;
  int _countdown = 3;
  bool _isCapturing = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<CameraDescription>? _cameras;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize camera after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCameras();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isNavigating) {
        _initializeCamera();
      }
    }
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _setError('No cameras available on this device');
        return;
      }
      await _initializeCamera();
    } catch (e) {
      _setError('Failed to load cameras: $e');
    }
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        await _controller!.dispose();
      }
      _controller = null;

      if (mounted) {
        setState(() {
          _isControllerInitialized = false;
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    if (_isNavigating) return;

    try {
      // Dispose old controller if exists
      await _disposeController();

      if (_cameras == null || _cameras!.isEmpty) {
        await _loadCameras();
        return;
      }

      // Find the requested camera
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == widget.cameraDirection,
        orElse: () => _cameras!.first,
      );

      // Create a new controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize the controller
      await _controller!.initialize();

      if (mounted && !_isNavigating) {
        setState(() {
          _isControllerInitialized = true;
        });

        // Start the countdown after camera is initialized
        _startCountdown();
      }
    } catch (e) {
      _setError('Camera initialization error: $e');
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  void _startCountdown() {
    if (_isNavigating) return;

    setState(() {
      _countdown = 3;
    });

    _runCountdown();
  }

  void _runCountdown() {
    if (!mounted || _isNavigating) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isNavigating) {
        setState(() {
          _countdown--;
        });

        if (_countdown > 0) {
          _runCountdown();
        } else {
          _capturePhoto();
        }
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_isControllerInitialized || _isNavigating) {
      _setError('Camera is not ready');
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Ensure flash is off for consistent results
      await _controller!.setFlashMode(FlashMode.off);

      // Take the picture
      final XFile image = await _controller!.takePicture();
      print('Image captured at: ${image.path}');

      // Set navigating flag to prevent camera reinitialization during navigation
      _isNavigating = true;

      // Properly release camera resources before navigating
      await _disposeController();

      // Handle the captured photo based on direction
      if (widget.cameraDirection == CameraLensDirection.front) {
        // If this is the front camera, navigate to back camera capture
        if (mounted) {
          // Use pushReplacement to avoid keeping the old page in memory
          context.pushReplacement(
            '/auto-capture',
            extra: {
              'direction': CameraLensDirection.back,
              'emergencyType': widget.emergencyType,
              'frontPhotoPath': image.path,
            },
          );
        }
      } else {
        // If this is the back camera, navigate directly to audio recording
        if (mounted) {
          context.pushReplacement(
            '/auto-record',
            extra: {
              'emergencyType': widget.emergencyType,
              'frontPhotoPath': widget.frontPhotoPath!,
              'backPhotoPath': image.path,
            },
          );
        }
      }
    } catch (e) {
      print('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing photo: $e')));

        // Reset capturing state and retry
        setState(() {
          _isCapturing = false;
          _isNavigating = false;
        });
        _startCountdown();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _controller == null || !_isControllerInitialized
              ? _buildLoadingView()
              : _buildCameraView(),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                'Camera Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = '';
                    _isNavigating = false;
                  });
                  _loadCameras();
                },
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Initializing camera...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.cameraDirection == CameraLensDirection.front
                      ? 'Front Camera'
                      : 'Back Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Camera preview with fixed aspect ratio
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4, // Fixed aspect ratio for better appearance
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom message and countdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.black,
            child: Column(
              children: [
                // Countdown indicator
                if (_countdown > 0 && !_isCapturing)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16.0),

                // Status message
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (_isCapturing)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          _isCapturing
                              ? 'Processing...'
                              : 'Photo will be captured in $_countdown seconds',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
