import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Result screen that shows recognized text and allows retake or pronunciation
class ResultView extends StatelessWidget {
  final String text; // the recognized text from the image
  final Function onRetake; // callback to go back to the camera
  final FlutterTts tts = FlutterTts(); // text-to-speech instance

  ResultView({
    required this.text,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    // set header height to take around half the screen
    double headerHeight = MediaQuery.of(context).size.height * 0.52;

    return Scaffold(
      body: Stack(
        children: [
          // background color
          Container(color: Color(0xFFD0ECE7)),

          // top background image (decorative)
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ManhalBackground2.png',
              fit: BoxFit.cover,
              height: headerHeight,
            ),
          ),

          // main UI content
          Column(
            children: [
              // upper section with result text and sound button
              Container(
                height: headerHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
  children: [
    Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 32, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    const SizedBox(height: 20),

    // النص القابل للتمدد
    Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              fontFamily: 'Blabeloo',
            ),
          ),
        ),
      ),
    ),

    const SizedBox(height: 20),

    // أيقونة الصوت
    IconButton(
      icon: Image.asset('assets/images/high-volume.png', width: 48, height: 48),
      onPressed: () => tts.speak(text),
    ),
  ],
),

              ),

              // bottom section with retake (camera) button
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => onRetake(),
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
                        // camera icon to retake a picture
                        child: Icon(Icons.camera_alt_outlined, size: 42, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
