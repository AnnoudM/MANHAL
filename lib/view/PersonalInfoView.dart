import 'package:flutter/material.dart';
import '../controller/PersonalInfoCont.dart';
import '../model/PersonalInfoModel.dart';

class PersonalInfoView extends StatefulWidget {
  final PersonalInfoModel parentInfo;

  const PersonalInfoView({super.key, required this.parentInfo});

  @override
  _PersonalInfoViewState createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  final PersonalInfoController _controller = PersonalInfoController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'معلوماتي الشخصية',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'alfont',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField(
                'الاسم',
                widget.parentInfo.name,
                Icons.edit,
                () => _showEditDialog('تعديل الاسم', widget.parentInfo.name, (newName) {
                  _controller.updateUserName(context, newName);
                }),
              ),
              _buildEditableField(
                'البريد الإلكتروني',
                widget.parentInfo.email,
                Icons.edit,
                () => _showEditDialog('تعديل البريد الإلكتروني', widget.parentInfo.email, (newEmail) {
                  _controller.updateUserEmail(context, newEmail);
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                child: Text('تغيير كلمة المرور للإعدادات', style: TextStyle(fontFamily: 'alfont')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _controller.deleteUserAccount(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text('حذف الحساب', style: TextStyle(fontFamily: 'alfont')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(value, style: TextStyle(fontSize: 18, fontFamily: 'alfont')),
      onTap: onTap,
    );
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController textController = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontFamily: 'alfont')),
          content: TextField(controller: textController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () {
                onSave(textController.text);
                Navigator.pop(context);
              },
              child: Text('حفظ', style: TextStyle(fontFamily: 'alfont')),
            ),
          ],
        );
      },
    );
  }
}
