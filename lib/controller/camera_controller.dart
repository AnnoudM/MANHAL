import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  /// 🔹 تهيئة الكاميرا عند تشغيل التطبيق
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.medium);
    await _controller!.initialize();
  }

  /// 🔹 التقاط صورة وإرجاع مسارها
  Future<String?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    XFile image = await _controller!.takePicture();
    return image.path;
  }

  /// 🔹 إغلاق الكاميرا لتوفير الموارد
  void disposeCamera() {
    _controller?.dispose();
  }

  /// 🔹 جلب الـ Controller الحالي (للاستخدام في CameraPreview)
  CameraController? getController() {
    return _controller;
  }
}
