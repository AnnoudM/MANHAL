import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controller/camera_controller.dart'; // ✅ استدعاء الكاميرا كنترولر
import '../view/result_view.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraService _cameraService = CameraService(); // ✅ استخدام كنترولر الكاميرا
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    setState(() {}); // تحديث الواجهة بعد التهيئة
  }

  Future<void> _captureAndSendImage() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });

    try {
      String? imagePath = await _cameraService.captureImage();
      if (imagePath == null) {
        print("❌ No image captured!");
        return;
      }

      print("📸 Captured image path: $imagePath");

      // إرسال الصورة إلى السيرفر
      String? recognizedText = await _sendImageToServer(imagePath);

      if (recognizedText != null && recognizedText.isNotEmpty) {
        print("✅ Recognized text: $recognizedText");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultView(
              text: recognizedText, // ✅ تمرير النص المستخرج
              onHome: () => Navigator.popUntil(context, ModalRoute.withName('/')), // ✅ زر الرجوع للصفحة الرئيسية
              onRetake: () => Navigator.pop(context), // ✅ زر إعادة الالتقاط
            ),
          ),
        );
      } else {
        print("⚠️ No text found!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لم يتم العثور على نص، حاول مرة أخرى!")),
        );
      }
    } catch (e) {
      print("❌ Error capturing image: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<String?> _sendImageToServer(String imagePath) async {
    try {
      print("📡 Sending image to server...");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.11.248:5000/recognize'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print("🔹 Server response: $responseBody");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        return jsonResponse['text'];
      } else {
        print("❌ Error: ${response.statusCode} - $responseBody");
      }
    } catch (e) {
      print("❌ Exception while sending image: $e");
    }
    return null;
  }

  @override
  void dispose() {
    _cameraService.disposeCamera(); // ✅ إغلاق الكاميرا عند مغادرة الصفحة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraService.getController() == null ||
        !_cameraService.getController()!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_cameraService.getController()!), // ✅ استخدام الكاميرا من الكنترولر
          Positioned(
            bottom: 50,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.camera, color: Colors.red, size: 50),
                  onPressed: _captureAndSendImage,
                ),
                SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.home, color: Colors.blue, size: 40),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
