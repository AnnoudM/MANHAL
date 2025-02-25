import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultView extends StatelessWidget {
  final String text;
  final Function onHome;
  final Function onRetake;
  final FlutterTts tts = FlutterTts();

  ResultView({required this.text, required this.onHome, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(text, style: TextStyle(fontSize: 40)),
          IconButton(
            icon: Icon(Icons.volume_up, size: 40),
            onPressed: () => tts.speak(text),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 40),
                onPressed: () => onHome(),
              ),
              IconButton(
                icon: Icon(Icons.camera, size: 40),
                onPressed: () => onRetake(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
