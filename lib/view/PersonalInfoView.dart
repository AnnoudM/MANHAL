import 'package:flutter/material.dart';
import '../controller/PersonalInfoCont.dart';
import '../model/PersonalInfoModel.dart';
import 'package:flutter/services.dart';


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
        backgroundColor: Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEditableField(
                    context,
                    'الاسم',
                    widget.parentInfo.name,
                    () => _showEditDialog(
                      'تعديل الاسم',
                      widget.parentInfo.name,
                      (newName) {
                        _controller.updateUserName(context, newName, (updatedName) {
                          setState(() {
                            widget.parentInfo.name = updatedName;
                          });
                        });
                      },
                    ),
                  ),
                  _buildEditableField(
                    context,
                    'البريد الإلكتروني',
                    widget.parentInfo.email,
                    () => _showEditDialog(
                      'تعديل البريد الإلكتروني',
                      widget.parentInfo.email,
                      (newEmail) => _controller.updateUserEmail(context, newEmail),
                    ),
                  ),
                  const Spacer(),
                  _buildActionButton(context, 'تغيير كلمة مرور الاعدادات', Colors.grey[300]!, () {}),
                  const SizedBox(height: 15),
                  _buildActionButton(context, 'حذف الحساب', Colors.redAccent, () {
                    _controller.deleteUserAccount(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value, VoidCallback onTap) {
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
            '$label: $value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'alfont',
            ),
          ),
          trailing: const Icon(Icons.edit, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'alfont',
        ),
      ),
    );
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
  TextEditingController textController = TextEditingController(text: initialValue);
  final _formKey = GlobalKey<FormState>(); // مفتاح النموذج للتحقق من الإدخال

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFFF8F8F8), 
        title: Text(title, style: TextStyle(fontFamily: 'alfont')),
        content: Form(
          key: _formKey, // إضافة النموذج للتحقق من صحة البيانات
          child: TextFormField(
            controller: textController,
            textDirection: TextDirection.rtl,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')), // السماح فقط بالأحرف العربية
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال الاسم'; // رسالة خطأ إذا كان فارغًا
              }
              return null; // لا توجد أخطاء
            },
            decoration: InputDecoration(
              hintText: 'أدخل الاسم الجديد',
              hintStyle: const TextStyle(fontFamily: 'alfont'),
              filled: true,
              fillColor: const Color(0xFFFFF5CC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
            ),
            style: const TextStyle(fontFamily: 'alfont'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) { // التحقق من صحة الإدخال
                onSave(textController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('حفظ', style: TextStyle(fontFamily: 'alfont')),
          ),
        ],
      );
    },
  );
}

}

