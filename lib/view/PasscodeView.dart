import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/PasscodeCont.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/PasscodeModel.dart';

class PasscodeView extends StatelessWidget {
  final String selectedChildId;
  final String currentParentId;
  final String parentId;

  const PasscodeView({
    Key? key,
    required this.parentId,
    required this.selectedChildId,
    required this.currentParentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasscodeController()..checkPasscodeStatus(parentId),
      child: Consumer<PasscodeController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Background
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
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("isParentArea", false);
                      Navigator.pop(context);
                    },
                  ),
                ),
                // Main content
                Center(
                  child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.hasPasscode
                                  ? "أدخل الرقم السري"
                                  : (controller.isConfirming ? "تأكيد الرمز السري" : "أدخل رقم سري جديد للإعدادات"),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'alfont', color: Colors.black),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              ('${'*' * controller.enteredPasscode.length}'.padRight(4, '•')),
                              style: const TextStyle(fontSize: 32, letterSpacing: 8, fontFamily: 'alfont', color: Colors.black),
                            ),
                            const SizedBox(height: 20),
                            if (controller.errorMessage != null)
                              Text(
                                controller.errorMessage!,
                                style: const TextStyle(color: Colors.red, fontFamily: 'alfont', fontSize: 16),
                              ),
                            const SizedBox(height: 20),
                            _buildNumberPad(controller, context),
                            const SizedBox(height: 40),
                            // Forgot passcode link
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final TextEditingController passwordController = TextEditingController();
                                    String? errorText;

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: const Text(
                                            "إعادة تعيين الرقم السري",
                                            style: TextStyle(fontFamily: 'alfont', fontSize: 20, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "أدخل كلمة المرور لحسابك لتأكيد هويتك",
                                                style: TextStyle(fontFamily: 'alfont', fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: passwordController,
                                                obscureText: true,
                                                decoration: const InputDecoration(
                                                  hintText: "كلمة المرور",
                                                  hintStyle: TextStyle(fontFamily: 'alfont'),
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: const TextStyle(fontFamily: 'alfont'),
                                              ),
                                              if (errorText != null) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  errorText!,
                                                  style: const TextStyle(color: Colors.red, fontFamily: 'alfont'),
                                                ),
                                              ]
                                            ],
                                          ),
                                          actionsAlignment: MainAxisAlignment.center,
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("إلغاء", style: TextStyle(fontFamily: 'alfont', fontSize: 16)),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  final auth = FirebaseAuth.instance;
                                                  final user = auth.currentUser;

                                                  if (user != null) {
                                                    final credential = EmailAuthProvider.credential(
                                                      email: user.email!,
                                                      password: passwordController.text,
                                                    );
                                                    await user.reauthenticateWithCredential(credential);
                                                    await PasscodeModel().clearPasscode(parentId);

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PasscodeView(
                                                          parentId: parentId,
                                                          selectedChildId: selectedChildId,
                                                          currentParentId: currentParentId,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    setState(() => errorText = "حدث خطأ، حاول لاحقًا");
                                                  }
                                                } catch (e) {
                                                  setState(() => errorText = "كلمة المرور غير صحيحة");
                                                }
                                              },
                                              child: const Text("تأكيد", style: TextStyle(fontFamily: 'alfont', fontSize: 16)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                "نسيت الرقم السري؟",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'alfont',
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Custom number pad widget
  Widget _buildNumberPad(PasscodeController controller, BuildContext context) {
    List<String> numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", ""];

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: numbers.length,
      itemBuilder: (context, index) {
        if (index == 9) {
          // Delete button
          return GestureDetector(
            onTap: () => controller.deleteLastDigit(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
              ),
              child: const Center(
                child: Icon(Icons.backspace, color: Colors.black, size: 30),
              ),
            ),
          );
        }

        String number = numbers[index];
        if (number.isEmpty) return const SizedBox();

        return GestureDetector(
          onTap: () async {
            if (controller.enteredPasscode.length < 4) {
              controller.updateEnteredPasscode(number);

              if (controller.enteredPasscode.length == 4) {
                bool success = await controller.submitPasscode(parentId);
                if (success) {
                  Navigator.pushReplacementNamed(context, "/settings", arguments: {
                    'selectedChildId': selectedChildId.isNotEmpty ? selectedChildId : null,
                    'currentParentId': parentId,
                  });
                }
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 24, fontFamily: 'alfont', color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
}
