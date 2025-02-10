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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // زر الرجوع في أعلى اليمين
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
                Navigator.pop(context); // العودة إلى الصفحة السابقة
              },
            ),
          ),

          // المحتوى
          StreamBuilder<DocumentSnapshot>(
            stream: _controller.childStream(), // 🔹 متابعة أي تغييرات على الطفل
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("⚠️ لا توجد بيانات متاحة"));
              }

              var childData = snapshot.data!.data() as Map<String, dynamic>;
              String updatedPhotoUrl =
                  childData['photoUrl'] ?? 'assets/images/default_avatar.jpg';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(updatedPhotoUrl),
                        radius: 70,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectImageView(
                                childID: widget.childID,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.black),
                        iconSize: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    childData['name'] ?? "غير معروف",
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Blabeloo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "العمر:",
                            style: TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${childData['age'] ?? 'غير محدد'}",
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