import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // For Text-to-Speech functionality

class LearnNumberPage extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts(); // TTS instance

  // Function to speak the number "1" in Arabic
  void _speakNumber() async {
    await flutterTts.setLanguage("ar-SA"); // Set language to Arabic
    await flutterTts.speak("واحد"); // Speak the Arabic word for "one"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Top part white
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFFF9EAFB), // Light pink background for the main content
              width: double.infinity ,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "١", // Arabic numeral for 1
                    style: TextStyle(
                      fontSize: 200, // Larger font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily:'Blabeloo',
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _speakNumber, // Trigger the sound on tap
                    child: Image.asset(
                      'assets/images/high-volume.png', // Sound icon from assets
                      width: 60, // Increased size
                      height: 60,
                      fit: BoxFit.contain, 
                    ),
                  ),
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/images/carrot-vegetable.png', // Duck image
                    width: 160, // Increased size
                    height: 160,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white, // Bottom white background
            padding: EdgeInsets.symmetric(vertical: 20),
            child: InkWell(
              onTap: () {
                // Placeholder: Non-functional for now
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFFF9EAFB), // Light pink button color
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.black), // Icon as a placeholder
                    SizedBox(width: 10),
                    Text(
                      "التالي", // Arabic for "Next"
                      style: TextStyle(fontSize: 40, color: Colors.black , fontFamily:'Blabeloo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
