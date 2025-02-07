import 'package:flutter/material.dart';

class ChildProfileView extends StatelessWidget {
  final String name; // اسم المستخدم
  final String gender; // الجنس
  final int age; // العمر
  final VoidCallback onEditProfile; // زر تعديل الصورة

  const ChildProfileView({
    Key? key,
    required this.name,
    required this.gender,
    required this.age,
    required this.onEditProfile,
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
          // "معلوماتي" وسهم الرجوع
          Positioned(
            top: 40, // التحكم في ارتفاع "معلوماتي"
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'معلوماتي',
                  style: TextStyle(
                    fontFamily: 'Blabeloo',
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 48), // لإضافة مساحة بدلاً من زر إضافي
              ],
            ),
          ),
          // المحتوى
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورة البروفايل
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: const AssetImage('assets/images/dog.png'),
                    ),
                    IconButton(
                      onPressed: onEditProfile,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                      iconSize: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // اسم المستخدم
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Blabeloo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // معلومات الجنس والعمر
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoBox(title: 'العمر', value: '$age سنوات'),
                    const SizedBox(width: 20),
                    _buildInfoBox(title: 'الجنس', value: gender),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Blabeloo',
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Blabeloo',color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}