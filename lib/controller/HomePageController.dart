import 'package:flutter/material.dart';
import '../model/HomePageModel.dart';
import '../view/HomePageView.dart';
import '../view/ChildProfileView.dart';

class HomePageController extends StatefulWidget {
  const HomePageController({Key? key}) : super(key: key);

  @override
  _HomePageControllerState createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController> {
  late HomePageModel userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    await Future.delayed(const Duration(seconds: 2)); // محاكاة جلب البيانات
    setState(() {
      userModel = HomePageModel(userName: 'سارة'); // استبدل هذا ببيانات Firebase
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return HomePageView(
      userName: userModel.userName,
      onUserNameClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildProfileView(
              name: userModel.userName, // اسم المستخدم
              gender: 'أنثى', // الجنس
              age: 4, // العمر
              onEditProfile: () {
                // منطق تعديل البروفايل
                print('تعديل البروفايل');
              },
            ),
          ),
        );
      },
      onScanImageClick: () {
        // منطق مسح الصورة
        print('مسح الصورة');
      },
    );
  }
}