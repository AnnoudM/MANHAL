import 'package:flutter/material.dart';
import '../controller/ChildProfileController.dart';
import '../view/SelectImageView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfileView extends StatefulWidget {
  final String name;
  final String gender;
  final int age;
  final String photoUrl;
  final String childID;

  const ChildProfileView({
    Key? key,
    required this.name,
    required this.gender,
    required this.age,
    required this.photoUrl,
    required this.childID,
  }) : super(key: key);

  @override
  _ChildProfileViewState createState() => _ChildProfileViewState();
}

class _ChildProfileViewState extends State<ChildProfileView> {
  late ChildProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChildProfileController(childID: widget.childID);
  }

  // Convert digits from English to Arabic
  String _convertToArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Real-time data from Firestore
          StreamBuilder<DocumentSnapshot>(
            stream: _controller.childStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("⚠️ لا توجد بيانات متاحة"));
              }

              var childData = snapshot.data!.data() as Map<String, dynamic>;
              String updatedPhotoUrl = childData['photoUrl'] ?? 'assets/images/default_avatar.jpg';
              String age = childData['age'] != null
                  ? _convertToArabicNumber(childData['age'].toString())
                  : 'غير محدد';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture with edit button
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(updatedPhotoUrl),
                        radius: 70,
                      ),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectImageView(childID: widget.childID),
                              ),
                            );
                          },
                          icon: Image.asset(
                            'assets/images/editAvatar.png',
                            width: 50,
                            height: 50,
                          ),
                          iconSize: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Child name
                  Text(
                    childData['name'] ?? "غير معروف",
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Blabeloo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Age and gender fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "العمر:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            age,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text(
                            "الجنس:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            childData['gender'] ?? "غير محدد",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
