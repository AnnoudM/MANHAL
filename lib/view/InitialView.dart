import 'package:flutter/material.dart';
import '../controller/initialController.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final InitialPageController controller = InitialPageController();
    final model = controller.model;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center( // توسيط جميع العناصر في الشاشة
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // توسيط أفقي
            children: [
              // شعار التطبيق مع تعديل المقاسات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  model.logoPath,
                  height: MediaQuery.of(context).size.height * 0.25, // جعل الصورة تستجيب لحجم الشاشة
                  width: MediaQuery.of(context).size.width * 0.5, // جعل عرض الصورة مناسب للشاشة
                  fit: BoxFit.contain, // التأكد من أن الصورة لا تفقد أبعادها الأصلية
                ),
              ),
              const SizedBox(height: 20),
              // نص الترحيب
              Text(
                model.welcomeText,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // زر الانضمام إلى منهل (SignUp)
              _buildButton(
                 context: context, 
                text: model.signUpButtonText,
                onPressed: () => controller.navigateToSignUp(context),
              ),
              const SizedBox(height: 15),
              // زر تسجيل الدخول (LogIn)
              _buildButton(
                 context: context, 
                text: model.loginButtonText,
                onPressed: () => controller.navigateToLogIn(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required BuildContext context, required String text, required VoidCallback onPressed}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.7, // جعل عرض الزر يتناسب مع الشاشة
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFE08A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );
}
}