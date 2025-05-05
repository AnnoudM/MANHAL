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
  String? _selectedAge;
  String? _selectedPhoto;

  final ChildController _controller = ChildController();

  // Arabic numbers for age dropdown
  final List<Map<String, String>> _ageOptions = [
    {'display': '٣', 'value': '٣'},
    {'display': '٤', 'value': '٤'},
    {'display': '٥', 'value': '٥'},
    {'display': '٦', 'value': '٦'},
    {'display': '٧', 'value': '٧'},
    {'display': '٨', 'value': '٨'},
  ];

  late List<DropdownMenuItem<String>> _ageDropdownItems;

  @override
  void initState() {
    super.initState();
    // Convert age list to dropdown items
    _ageDropdownItems = _ageOptions.map((item) {
      return DropdownMenuItem<String>(
        value: item['value'],
        child: Text(
          item['display']!,
          style: const TextStyle(fontFamily: 'alfont', color: Colors.black),
        ),
      );
    }).toList();
  }

  // Called when submit button is pressed
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String childId = FirebaseFirestore.instance.collection('Children').doc().id;
      Child child = Child(
        id: childId,
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        age: int.parse(_arabicToEnglishNumber(_selectedAge!)), // Convert Arabic number to English
        photoUrl: _selectedPhoto,
        parentId: widget.parentId,
      );
      await _controller.addChildToParent(context, widget.parentId, child);
    }
  }

  // Reusable input field for name
  _buildTextField({
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
      validator: (value) {
        if (value!.isEmpty) return 'هذا الحقل مطلوب';
        final arabicNameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
        final hasNumbers = RegExp(r'[0-9\u0660-\u0669]').hasMatch(value);
        if (hasNumbers) return 'الاسم لا يمكن أن يحتوي على أرقام';
        if (!arabicNameRegex.hasMatch(value)) return 'الرجاء إدخال الاسم بالحروف العربية فقط';
        if (value.trim().isEmpty) return 'الاسم لا يمكن أن يكون فارغًا أو يحتوي على مسافات فقط';
        return null;
      },
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

  // Convert English digits to Arabic
  String _convertToArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  // Convert Arabic digits to English
  String _arabicToEnglishNumber(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  // Reusable dropdown field (gender or age)
  Widget _buildDropdownField({
    required String hintText,
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      selectedItemBuilder: hintText == 'العمر'
          ? (context) {
              return items.map((DropdownMenuItem<String> item) {
                return Text(
                  _convertToArabicNumber(item.value ?? ''),
                  style: const TextStyle(fontFamily: 'alfont', color: Colors.black),
                );
              }).toList();
            }
          : null,
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

  // Reusable submit button
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
            // Main form
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        // Select photo
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
                              child: Icon(Icons.edit, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name input
                        _buildTextField(
                          hintText: 'اسم الطفل باللغة العربية',
                          controller: _nameController,
                          validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Gender dropdown
                        _buildDropdownField(
                          hintText: 'الجنس',
                          items: ['ذكر', 'أنثى']
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item, style: const TextStyle(fontFamily: 'alfont', color: Colors.black)),
                                  ))
                              .toList(),
                          value: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value),
                          validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
                        ),
                        const SizedBox(height: 15),
                        // Age dropdown
                        _buildDropdownField(
                          hintText: 'العمر',
                          items: _ageDropdownItems,
                          value: _selectedAge,
                          onChanged: (value) => setState(() => _selectedAge = value),
                          validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
                        ),
                        const SizedBox(height: 30),
                        // Submit button
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
