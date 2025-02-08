import 'package:flutter/material.dart';
import '../view/SelectImageView.dart';

class ChildProfileView extends StatelessWidget {
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

          // زر الرجوع
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

          // المحتوى الرئيسي
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورة الطفل مع زر التعديل
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(photoUrl),
                      radius: 70,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectImageView(childID: childID),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                      iconSize: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // اسم الطفل
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontFamily: 'Blabeloo',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),

                // العمر والجنس جنب بعض
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoBox(title: "العمر", value: "$age"),
                    const SizedBox(width: 40), // مسافة بين العناصر
                    _buildInfoBox(title: "الجنس", value: gender),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 عنصر معلومات العمر والجنس
  Widget _buildInfoBox({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Blabeloo',
            color: Colors.grey, // لون رمادي للعناوين
          ),
        ),
        const SizedBox(height: 5), // مسافة بين العنوان والقيمة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20, // تكبير الخط
              fontWeight: FontWeight.bold,fontFamily: 'Blabeloo',
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}