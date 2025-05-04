import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controller/camera_controller.dart';
import '../view/result_view.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraService _cameraService = CameraService();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    setState(() {});
  }

  Future<void> _captureAndSendImage() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });

    try {
      String? imagePath = await _cameraService.captureImage();
      if (imagePath == null) return;

      String? recognizedText = await _sendImageToServer(imagePath);
      print("📄 النص المستخرج: $recognizedText");

      if (recognizedText != null && recognizedText.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultView(
              text: recognizedText,
              onHome: () => Navigator.popUntil(context, ModalRoute.withName('/')),
              onRetake: () => Navigator.pop(context),
            ),
          ),
        );
      } else {
        print("🚫 لم يتم التعرف على نص.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لم يتم العثور على نص، حاول مرة أخرى!")),
        );
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<String?> _sendImageToServer(String imagePath) async {
    print("🚀 نحاول نرسل الصورة للسيرفر...");

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.43:5000/recognize')
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📩 رد السيرفر بالكامل: $responseBody");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        print("✅ النص المستخرج: \${jsonResponse['text']}");
        return jsonResponse['text'];
      } else {
        print("⚠️ السيرفر رجع خطأ: \${response.statusCode}");
        print("❗️ تفاصيل الخطأ: $responseBody");
      }
    } catch (e) {
      print("❌ Exception أثناء الإرسال: $e");
    }

    return null;
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BackGroundManhal.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                  child: Text(
                    "التقط لنتعلم!",
                    style: TextStyle(
                      fontFamily: "Blabeloo",
                      fontSize: 26,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: _cameraService.getController()!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CameraPreview(_cameraService.getController()!),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: GestureDetector(
                  onTap: _captureAndSendImage,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_outlined, size: 42, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}