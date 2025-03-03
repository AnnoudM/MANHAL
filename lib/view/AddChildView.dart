import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/child_model.dart';
import '../view/SelectImageView.dart';
import '../controller/ChildController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddChildView extends StatefulWidget {
  final String parentId;
  const AddChildView({super.key, required this.parentId});

  @override
  _AddChildViewState createState() => _AddChildViewState();
}

class _AddChildViewState extends State<AddChildView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGender;
  int? _age;
  String? _selectedPhoto;

  final ChildController _controller = ChildController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String childId = FirebaseFirestore.instance.collection('Children').doc().id; // إنشاء id جديد
Child child = Child(
  id: childId,  // تمرير id للطفل
  name: _nameController.text.trim(),
  gender: _selectedGender!,
  age: _age!,
  photoUrl: _selectedPhoto,
  parentId: widget.parentId,
);


      await _controller.addChildToParent(context, widget.parentId, child);
    }
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
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
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item,
    style: const TextStyle(fontFamily: 'alfont', color: Colors.black),),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
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
      validator: validator,
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
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
            fontFamily: 'alfont',
          ),
        ),
      ),
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
          /// ✅ **إضافة الخلفية**
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ✅ **زر الرجوع (بدون AppBar)**
          Positioned(
            top: 50, // لضبط موقع زر الرجوع مثل السابق
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          /// ✅ **العنوان**
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                'إضافة طفل',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'alfont',
                ),
              ),
            ),
          ),

          /// ✅ **المحتوى الرئيسي**
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50), // ✅ لمنع التداخل مع العنوان وزر الرجوع
                      GestureDetector(
                        onTap: () async {
                          final selectedPhoto = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SelectImageView()),
                          );
                          if (selectedPhoto != null) {
                            setState(() {
                              _selectedPhoto = selectedPhoto;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedPhoto != null
                              ? AssetImage(_selectedPhoto!)
                              : const AssetImage('assets/images/default_avatar.jpg'),
                          child: const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        hintText: 'اسم الطفل باللغة العربية',
                        controller: _nameController,
                        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildDropdownField(
                        hintText: 'الجنس',
                        items: ['ذكر', 'أنثى'],
                        value: _selectedGender,
                        onChanged: (value) => setState(() => _selectedGender = value),
                        validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        hintText: 'العمر',
                        controller: TextEditingController(text: _age?.toString()),
                        keyboardType: TextInputType.number,
                        validator: (value) => (value == null || int.tryParse(value) == null)
                            ? 'يرجى إدخال عمر صحيح'
                            : null,
                        onChanged: (value) => _age = int.tryParse(value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildButton(
                        text: 'إضافة',
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
} 
