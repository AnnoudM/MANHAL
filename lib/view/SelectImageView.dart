import 'package:flutter/material.dart';

class SelectImageView extends StatelessWidget {
  const SelectImageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
     'assets/images/boy1.png',
      'assets/images/boy1.png',
      'assets/images/boy2.png',
      'assets/images/boy3.png',
      'assets/images/boy4.png',
      'assets/images/boy5.png',
      'assets/images/girl.png',
      'assets/images/girl1.png',
      'assets/images/girl2.png',
      'assets/images/girl3.png',
      'assets/images/girl4.png',
      'assets/images/girl5.png',
    ];

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
                Navigator.pop(context); // العودة إلى الشاشة السابقة
              },
            ),
          ),
          // المحتوى الرئيسي
          Column(
            children: [
              const SizedBox(height: 60), // مساحة أعلى للعنوان
              const Text(
                "اختر صورة",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Blabeloo',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // عدد الصور في كل صف
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // زر الحفظ
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3CD), // لون الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // حواف دائرية
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // يغلق الصفحة عند الضغط
                    },
                    child: const Text(
                      "حفظ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Blabeloo',
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