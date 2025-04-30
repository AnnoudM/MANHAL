import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultView extends StatelessWidget {
  final String text;
  final Function onHome;
  final Function onRetake;
  final FlutterTts tts = FlutterTts();

  ResultView({
    required this.text,
    required this.onHome,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    double headerHeight = MediaQuery.of(context).size.height * 0.52;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Color(0xFFD0ECE7)),

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

          Column(
            children: [
              Container(
                height: headerHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
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
                    const SizedBox(height: 20),
                    IconButton(
                      icon: Image.asset('assets/images/high-volume.png', width: 48, height: 48),
                      onPressed: () => tts.speak(text),
                    ),
                  ],
                ),
              ),

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => onHome(),
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
                          child: Icon(Icons.home, size: 42, color: Colors.black),
                        ),
                      ),
                      GestureDetector(
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
                          child: Icon(Icons.camera_alt_outlined, size: 42, color: Colors.black),
                        ),
                      ),
                    ],
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