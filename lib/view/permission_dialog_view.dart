import 'package:flutter/material.dart';

class PermissionDialogView extends StatelessWidget {
  final Function onGranted;
  final Function onDenied;

  PermissionDialogView({required this.onGranted, required this.onDenied});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("هل تسمح لتطبيق منهل بالوصول إلى الكاميرا؟"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 40),
                  onPressed: () => onDenied(),
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green, size: 40),
                  onPressed: () => onGranted(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
