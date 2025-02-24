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
      create: (_) => PasscodeController()..checkIfNewParent(parentId),
      child: Consumer<PasscodeController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("أدخل الرقم السري", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(controller.enteredPasscode.padRight(4, '•'),
                    style: const TextStyle(fontSize: 32, letterSpacing: 8)),
                const SizedBox(height: 20),
                if (controller.errorMessage != null)
                  Text(controller.errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                _buildNumberPad(controller),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // وظيفة استعادة كلمة السر عند الحاجة
                  },
                  child: const Text("نسيت الرقم السري؟", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberPad(PasscodeController controller) {
  return GridView.builder(
    shrinkWrap: true,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
    ),
    itemCount: 10,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () async {
          if (controller.enteredPasscode.length < 4) {
            controller.updateEnteredPasscode(index.toString());
            if (controller.enteredPasscode.length == 4) {
              bool success = await controller.submitPasscode(parentId);
              if (success) {
                Navigator.pushReplacementNamed(context, "/settings", arguments: {
                  'selectedChildId': selectedChildId,
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
          child: Center(child: Text(index.toString(), style: TextStyle(fontSize: 24))),
        ),
      );
    },
  );
}
}
