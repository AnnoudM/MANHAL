import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/ChildController.dart';
import '../model/child_model.dart';
import '../view/SelectImageView.dart';
import '../view/ChildListView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildPageView extends StatefulWidget {
  final Child child;

  const ChildPageView({super.key, required this.child});

  @override
  _ChildPageViewState createState() => _ChildPageViewState();
}

class _ChildPageViewState extends State<ChildPageView> {
  final ChildController _controller = ChildController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late String? _selectedPhoto;
  late Child _child;

  String _convertToArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController textController = TextEditingController(text: initialValue);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
          title: Text(title, style: const TextStyle(fontFamily: 'alfont')),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: textController,
              validator: (value) {
                if (value!.isEmpty) return 'هذا الحقل مطلوب';
                if (title.contains('الاسم') && !RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value)) {
                  return 'يُسمح فقط بالأحرف العربية';
                }
                if (value.trim().isEmpty) {
                  return 'الاسم لا يمكن أن يحتوي على مسافات فقط';
                }
                if (RegExp(r'[0-9\u0660-\u0669]').hasMatch(value)) {
                  return 'يُمنع إدخال الأرقام في الاسم';
                }
                return null;
              },
              inputFormatters: title.contains('الاسم')
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^[\u0600-\u06FF\s]+$'))]
                  : [FilteringTextInputFormatter.digitsOnly],
              keyboardType: title.contains('العمر') ? TextInputType.number : TextInputType.text,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
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
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String newValue = textController.text.trim();
                  if (title.contains('الاسم')) {
                    setState(() {
                      _child = _child.copyWith(name: newValue);
                    });
                  }
                  try {
                    await _controller.updateChildInfo(_child, (updatedChild) {
                      setState(() {
                        _child = updatedChild;
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم التعديل بنجاح', style: TextStyle(fontFamily: 'alfont')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ في التحديث: $e', style: const TextStyle(fontFamily: 'alfont')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'alfont')),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _child = widget.child;
    _nameController = TextEditingController(text: _child.name);
    _ageController = TextEditingController(text: _child.age.toString());
    _selectedPhoto = _child.photoUrl;
  }

  void _showAgeEditDialog() {
    List<String> ageOptions = ['3', '4', '5', '6', '7', '8'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
          title: const Text('تعديل العمر', style: TextStyle(fontFamily: 'alfont')),
          content: DropdownButtonFormField<String>(
            value: _child.age.toString(),
            items: ageOptions.map((age) {
              return DropdownMenuItem<String>(
                value: age,
                child: Text(_convertToArabicNumber(age), style: const TextStyle(fontFamily: 'alfont')),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _child = _child.copyWith(age: int.parse(value!));
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF5CC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم التعديل بنجاح', style: TextStyle(fontFamily: 'alfont')),
                    backgroundColor: Colors.green,
                  ),
                );
                await _controller.updateChildInfo(_child, (updatedChild) {
                  setState(() {
                    _child = updatedChild;
                  });
                });
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'alfont')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
              top: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 50),
                    const Text(
                      'معلومات الطفل',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'alfont',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 130, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final selectedPhoto = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectImageView()),
                        );
                        if (selectedPhoto != null) {
                          setState(() {
                            _selectedPhoto = selectedPhoto;
                            _child = _child.copyWith(photoUrl: selectedPhoto);
                          });
                          try {
                            await _controller.updateChildInfo(_child, (updatedChild) {
                              setState(() {
                                _child = updatedChild;
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تحديث الصورة بنجاح', style: TextStyle(fontFamily: 'alfont')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ في تحديث الصورة: $e', style: const TextStyle(fontFamily: 'alfont')),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(_selectedPhoto ?? 'assets/images/default_avatar.jpg'),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    'الاسم',
                    _child.name,
                    () => _showEditDialog('تعديل الاسم', _child.name, (newName) {
                      setState(() {
                        _child = _child.copyWith(name: newName);
                      });
                      _updateChildInfo();
                    }),
                  ),
                  _buildEditableField(
                    'العمر',
                    _convertToArabicNumber(_child.age.toString()),
                    () => _showAgeEditDialog(),
                  ),
                  _buildStaticField('الجنس', widget.child.gender),
                  const Spacer(),
                  _buildActionButton(context, 'حذف الطفل', Colors.redAccent, _deleteChild),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateChildInfo() async {
    if (_formKey.currentState?.validate() ?? true) {
      await _controller.updateChildInfo(_child, (updatedChildFromDB) {
        setState(() {
          _child = updatedChildFromDB;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعديل المعلومات بنجاح', style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  void _deleteChild() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
          title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'alfont')),
          content: const Text('هل أنت متأكد من حذف هذا الطفل؟', style: TextStyle(fontFamily: 'alfont')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _controller.deleteChild(widget.child.parentId, widget.child.id);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildListView()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الطفل بنجاح', style: TextStyle(fontFamily: 'alfont')),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('حذف', style: TextStyle(fontFamily: 'alfont', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(String label, String value, VoidCallback onTap) {
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
          title: Text('$label: $value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'alfont')),
          trailing: const Icon(Icons.edit, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
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
          title: Text('$label: $value', style: const TextStyle(fontSize: 18, fontFamily: 'alfont')),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'alfont'),
      ),
    );
  }
}
