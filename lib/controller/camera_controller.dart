import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  // setup camera on app start
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  // take a photo and return the path
  Future<String?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    XFile image = await _controller!.takePicture();
    return image.path;
  }

  // clean up the camera
  void disposeCamera() {
    _controller?.dispose();
  }

  // get camera controller for preview
  CameraController? getController() {
    return _controller;
  }
}
