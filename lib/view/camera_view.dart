import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts flutterTts = FlutterTts();
  bool isProcessing = false;

  // Text to show and speak initially
  final String displayText = "التقط الكلمة أو الجملة لنتعلمها معا";
  final String spokenText = "اِلتقِطِ الكَلِمَةَ أَوِ الجُملَةَ لِنَتَعَلَّمَها مَعًا";
  final String errorDisplayText = "الكلمة أو الجملة غير واضحة، التقط مرة أخرى!";
  final String errorSpokenText = "الكَلِمَةُ أَوِ الجُملَةُ غَيرُ واضِحَة، اِلتقِط مَرَّةً أُخرى!";

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Start the camera
    _speak(spokenText);  // Say intro text
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    setState(() {}); // Refresh UI after camera is ready
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text); // Read text out loud
  }

  // Take picture and send it to server
  Future<void> _captureAndSendImage() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });

    try {
      String? imagePath = await _cameraService.captureImage();
      if (imagePath == null) return;

      String? recognizedText = await _sendImageToServer(imagePath);

      if (recognizedText != null && recognizedText.isNotEmpty) {
        // Show result page if text was found
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultView(
              text: recognizedText,
              onRetake: () => Navigator.pop(context),
            ),
          ),
        );
      } else {
        // Show error if no text found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorDisplayText)),
        );
        _speak(errorSpokenText);
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Send image file to backend API
  Future<String?> _sendImageToServer(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.11.248:5000/recognize'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        return jsonResponse['text'];
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending to server: $e");
    }

    return null;
  }

  @override
  void dispose() {
    _cameraService.disposeCamera(); // Release camera
    flutterTts.stop();              // Stop any speech
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
              // Back button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Instruction text
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontFamily: "Blabeloo",
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Camera preview
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
              // Camera button
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
