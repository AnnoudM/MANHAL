import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  // Initialize camera when app starts
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  // Capture an image and return its path
  Future<String?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    XFile image = await _controller!.takePicture();
    return image.path;
  }

  // Dispose camera when not needed
  void disposeCamera() {
    _controller?.dispose();
  }

  // Return current controller (used for preview)
  CameraController? getController() {
    return _controller;
  }
}
