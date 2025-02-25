import 'package:flutter/material.dart';
import 'dart:io';

class ConfirmationView extends StatelessWidget {
  final String imagePath;
  final Function onAccept;
  final Function onRetake;

  ConfirmationView(
      {required this.imagePath, required this.onAccept, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.file(File(imagePath)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.red, size: 40),
                onPressed: () => onRetake(),
              ),
              IconButton(
                icon: Icon(Icons.check, color: Colors.green, size: 40),
                onPressed: () => onAccept(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
