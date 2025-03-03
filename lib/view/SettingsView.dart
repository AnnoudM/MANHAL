import 'package:flutter/material.dart';
import '../controller/SettingsCont.dart';
import '../model/SettingsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller = SettingsController();
  final String selectedChildId; // ✅ معرف الطفل المختار
  final String currentParentId; // ✅ معرف الوالد

  SettingsView({
    super.key,
    required this.selectedChildId,
    required this.currentParentId,
  });

 @override
Widget build(BuildContext context) {
  print('🔍 فتح SettingsView لمعرف الطفل: $selectedChildId، معرف الوالد: $currentParentId');
  
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ✅ **إضافة الخلفية**
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ✅ **زر الرجوع (بدون AppBar)**
          Positioned(
            top: 50, // لضبط موقع زر الرجوع مثل السابق
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("isParentArea", false); // ✅ إعادة isParentArea إلى false
                print("🔄 تم تعيين Parent Area إلى false عند الرجوع من الإعدادات");
                Navigator.pop(context); // ✅ العودة إلى الصفحة السابقة
              },
            ),
          ),

          /// ✅ **العنوان**
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                'الإعدادات',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'alfont',
                ),
              ),
            ),
          ),

          /// ✅ **المحتوى الرئيسي**
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20), // ✅ لضبط المحتوى بعد العنوان وزر الرجوع
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var setting in settingsOptions)
                  _buildSettingsOption(context, setting.title),
                const Spacer(),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSettingsOption(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'alfont',
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: () {
            controller.onSettingSelected(
              context,
              title, // ✅ يتم تمرير اسم الإعداد
               childId: selectedChildId.isNotEmpty ? selectedChildId : null,// ✅ تمرير معرف الطفل
              parentId: currentParentId, // ✅ تمرير معرف الوالد
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () => controller.logout(context),
      child: const Text(
        'تسجيل الخروج',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'alfont',
        ),
      ),
    );
  }
}
