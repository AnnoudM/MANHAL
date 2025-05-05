import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      textDirection: TextDirection.rtl, // Force RTL for Arabic UI
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background image
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
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Page title
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: const Text(
                  'معلوماتي الشخصية',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'alfont',
                  ),
                ),
              ),
            ),

            // Editable fields and actions
            Padding(
              padding: const EdgeInsets.only(top: 130, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
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
                      isEmail: false,
                    ),
                  ),
                  // Email field
                  _buildEditableField(
                    context,
                    'البريد الإلكتروني',
                    widget.parentInfo.email,
                    () => _showEditDialog(
                      'تغيير البريد الإلكتروني',
                      widget.parentInfo.email,
                      (newEmail) => _controller.updateUserEmail(context, newEmail),
                      isEmail: true,
                    ),
                  ),
                  const Spacer(),
                  // Delete account button
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

  // Widget for each field (name/email)
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

  // Button widget (used for delete account)
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

  // Edit dialog for name/email
  void _showEditDialog(String title, String initialValue, Function(String) onSave, {required bool isEmail}) {
    TextEditingController textController = TextEditingController(text: initialValue);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF8F8F8),
          title: Text(title, style: TextStyle(fontFamily: 'alfont')),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: textController,
              textDirection: isEmail ? TextDirection.ltr : TextDirection.rtl,
              keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  isEmail ? RegExp(r'[a-zA-Z0-9@._-]') : RegExp(r'[\u0600-\u06FF\s]'),
                ),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isEmail ? 'الرجاء إدخال البريد الإلكتروني' : 'الرجاء إدخال الاسم';
                } else if (isEmail &&
                    !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
                  return 'الرجاء إدخال بريد إلكتروني صالح';
                }

                if (!isEmail) {
                  final arabicNameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
                  final hasNumbers = RegExp(r'[0-9\u0660-\u0669]').hasMatch(value);
                  if (hasNumbers) {
                    return 'الاسم لا يمكن أن يحتوي على أرقام';
                  }
                  if (!arabicNameRegex.hasMatch(value)) {
                    return 'الرجاء إدخال الاسم بالحروف العربية فقط';
                  }
                  if (value.trim().isEmpty) {
                    return 'الاسم لا يمكن أن يكون فارغًا أو يحتوي على مسافات فقط';
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: isEmail ? 'أدخل البريد الإلكتروني الجديد' : 'أدخل الاسم الجديد باللغة العربية',
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
                if (_formKey.currentState!.validate()) {
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
