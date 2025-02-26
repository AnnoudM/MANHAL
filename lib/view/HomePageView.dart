import 'package:flutter/material.dart';
import '../view/ArabicWordsView.dart';
import 'dart:async'; // ✅ لاستعمال Timer

class HomePageView extends StatelessWidget {
  final String userName;
  final String gender;
  final int age;
  final String photoUrl;
  final String childID;
  final VoidCallback onScanImageClick;
  final VoidCallback onProfileClick;
  final VoidCallback onSettingsClick; // تم إضافة التنقل إلى صفحة الإعدادات
  final VoidCallback onStickersClick; // تم إضافة التنقل إلى صفحة الـ Stickers
  final Function(String) onItemClick; // التنقل إلى الصفحات

  const HomePageView({
    super.key,
    required this.userName,
    required this.age,
    required this.childID,
    required this.gender,
    required this.photoUrl,
    required this.onScanImageClick,
    required this.onProfileClick,
    required this.onSettingsClick,
    required this.onStickersClick,
    required this.onItemClick,
  });

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
          Column(
            children: [
              // ✅ الصف العلوي يحتوي على أيقونة الإعدادات و أيقونة الستكرز
              Padding(
                padding: const EdgeInsets.only(top: 35, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 أيقونة الستكرز
                    GestureDetector(
                      onTap: onStickersClick,
                      child: Image.asset(
                        'assets/images/stickers_icon.png', // استبدل بالمسار الصحيح
                        width: 40,
                        height: 40,
                      ),
                    ),
                    // 🔹 أيقونة الإعدادات
                    GestureDetector(
                      onTap: onSettingsClick,
                      child: const Icon(Icons.settings,
                          color: Colors.black, size: 35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // صورة الطفل
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(photoUrl),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                child: Text(
                  'مرحبًا $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Blabeloo',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // زر "ملفي الشخصي"
              ElevatedButton(
                onPressed: onProfileClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'ملفي الشخصي',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Blabeloo',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildMenuItem(
                        title: 'رحلة الأحرف',
                        color: Colors.lightBlue[100]!,
                        textColor: const Color(0xFF638297),
                        iconText: 'أ ب ج',
                        fontSize: 35,
                        iconSize: 60,
                        onTap: () => onItemClick('رحلة الأحرف'),
                      ),
                      _buildMenuItem(
                        title: 'رحلة الأرقام',
                        color: Colors.purple[100]!,
                        textColor: const Color(0xFF7A6B7D),
                        iconText: '١٢٣',
                        iconSize: 60,
                        onTap: () => onItemClick('رحلة الأرقام'),
                      ),
                      _buildMenuItem(
                        title: 'رحلة الكلمات',
                        color: Colors.yellow[100]!,
                        textColor: const Color(0xFFB1A782),
                        iconText: 'نتعلم',
                        iconSize: 70,
                        fontSize: 35,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ArabicWordsPage())),
                      ),
                      _buildMenuItem(
                        title: 'القيم الأخلاقية',
                        color: Colors.pink[100]!,
                        textColor: const Color.fromARGB(255, 124, 80, 108),
                        iconPath: 'assets/images/ethicalIcon.png',
                        iconSize: 60,
                        onTap: () => onItemClick('القيم الأخلاقية'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // زر "مسح الصورة"
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20, bottom: 30),
                child: ElevatedButton(
                  onPressed: onScanImageClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 197, 243, 235),
                    minimumSize: const Size(double.infinity, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/scanIcon.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'مسح الصورة',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Blabeloo',
                          color: Color(0xFF547F77),
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

  Widget _buildMenuItem({
    required String title,
    required Color color,
    required Color textColor,
    String? iconPath,
    String? iconText,
    double iconSize = 50,
    double fontSize = 40,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                Image.asset(
                  iconPath,
                  width: iconSize,
                  height: iconSize,
                ),
              if (iconText != null)
                Text(
                  iconText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'Blabeloo',
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Blabeloo',
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
