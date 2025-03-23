import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controller/camera_controller.dart'; // ✅ استدعاء الكنترولر
import '../view/result_view.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraService _cameraService = CameraService(); // ✅ استخدام الكنترولر
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
      if (imagePath == null) return;

      // إرسال الصورة إلى السيرفر
      String? recognizedText = await _sendImageToServer(imagePath);
      print("📄 النص المستخرج: $recognizedText");

      if (recognizedText != null && recognizedText.isNotEmpty) {
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
      Uri.parse('http://192.168.100.201:5000/recognize'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print("📩 رد السيرفر بالكامل: $responseBody");

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseBody);
      print("✅ النص المستخرج: ${jsonResponse['text']}");
      return jsonResponse['text'];
    } else {
      print("⚠️ السيرفر رجع خطأ: ${response.statusCode}");
      print("❗ تفاصيل الخطأ: $responseBody");
    }
  } catch (e) {
    print("❌ Exception أثناء الإرسال: $e");
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
    body: Column(
      children: [
        // ✅ عرض الكاميرا في الأعلى
        Expanded(
          flex: 4, // يجعل الكاميرا تأخذ أغلب الشاشة
          child: CameraPreview(_cameraService.getController()!),
        ),

        // ✅ وضع زر الالتقاط وزر الرجوع جنبًا إلى جنب فوق النص
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // يجعل الأزرار في المنتصف
            children: [
              // زر الالتقاط 📸
              IconButton(
                icon: Icon(Icons.camera, color: Colors.blue, size: 60),
                onPressed: _captureAndSendImage,
              ),
              SizedBox(width: 40), // مسافة بين الزرين

              // زر الرجوع إلى الصفحة الرئيسية 🏠
              IconButton(
                icon: Icon(Icons.home, color: Colors.blue, size: 60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // ✅ المساحة البيضاء تحتوي فقط على النص "التقط لنتعلم!"
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "التقط لنتعلم!",
              style: TextStyle(
                fontFamily: "Blabeloo", // ✅ استخدام الخط المفضل لديك
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
