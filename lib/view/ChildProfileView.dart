import 'package:flutter/material.dart';

class ChildProfileView extends StatelessWidget {
  final String name;
  final String gender;
  final int age;
  final String photoUrl;

  const ChildProfileView({
    Key? key,
    required this.name,
    required this.gender,
    required this.age,
    required this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(photoUrl),
                radius: 60,
              ),
              Text(name),
              Text('العمر: $age'),
              Text('الجنس: $gender'),
            ],
          ),
        ],
      ),
    );
  }
}