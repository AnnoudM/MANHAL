import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/PasscodeCont.dart';

class PasscodeView extends StatelessWidget {
  final String selectedChildId;
  final String currentParentId;
  final String parentId;

  const PasscodeView({Key? key, required this.parentId, required this.selectedChildId, required this.currentParentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasscodeController()..checkPasscodeStatus(parentId),
      child: Consumer<PasscodeController>(
        builder: (context, controller, child) {
          print("🔄 تحديث الواجهة - isLoading: ${controller.isLoading}");
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/BackGroundManhal.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
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
                              controller.enteredPasscode.padRight(4, '•'),
                              style: const TextStyle(fontSize: 32, letterSpacing: 8, fontFamily: 'alfont', color: Colors.black),
                            ),
                            const SizedBox(height: 20),
                            if (controller.errorMessage != null)
                              Text(controller.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontFamily: 'alfont', fontSize: 16)),
                            const SizedBox(height: 20),
                            _buildNumberPad(controller, context),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () async {
                                print("تم النقر على نسيت الرقم السري");
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
        String number = numbers[index];

        if (number.isEmpty) {
          return const SizedBox();
        }

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
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
              ],
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
