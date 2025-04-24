import 'package:camera/camera.dart';

abstract class CameraService {
  Future<void> initialize();
  Future<XFile> capturePhoto();
  Future<void> dispose();
}

class DeviceCameraService implements CameraService {
  final CameraDescription camera;
  late CameraController _controller;

  DeviceCameraService(this.camera);

  @override
  Future<void> initialize() async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.off);
  }

  @override
  Future<XFile> capturePhoto() async {
    return await _controller.takePicture();
  }

  @override
  Future<void> dispose() async {
    if (_controller.value.isInitialized) {
      await _controller.dispose();
    }
  }

  CameraController get controller => _controller;
  bool get isInitialized => _controller.value.isInitialized;
}
