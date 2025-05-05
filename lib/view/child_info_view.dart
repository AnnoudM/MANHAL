import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/signup_controller.dart';
import '../model/child_model.dart';
import '../model/signup_model.dart';
import '../view/InitialView.dart';
import '../view/SelectImageView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChildInfoView extends StatefulWidget {
  final SignUpModel? parentData;
  final String parentId;
  final String childId;

  const ChildInfoView(
      {super.key,
      this.parentData,
      required this.parentId,
      required this.childId});

  @override
  _ChildInfoViewState createState() => _ChildInfoViewState();
}

class _ChildInfoViewState extends State<ChildInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedAge;
  String? _selectedPhoto;
  String? _errorMessage;

  final SignUpController _controller = SignUpController();

  // List of age options in both display and value
  final List<Map<String, String>> _ageOptions = [
    {'display': '٣', 'value': '3'},
    {'display': '٤', 'value': '4'},
    {'display': '٥', 'value': '5'},
    {'display': '٦', 'value': '6'},
    {'display': '٧', 'value': '7'},
    {'display': '٨', 'value': '8'},
  ];

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

  // Called when user taps "تسجيل" button
  void _submit() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      if (widget.parentData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('بيانات الوالد غير متوفرة',
                  style: TextStyle(fontFamily: 'alfont'))),
        );
        return;
      }

      String childId =
          FirebaseFirestore.instance.collection('Children').doc().id;

      Child child = Child(
        id: widget.childId,
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        age: int.parse(_arabicToEnglishNumber(_selectedAge!)),
        photoUrl: _selectedPhoto,
        parentId: widget.parentId,
      );

      await _controller.registerParentAndChild(
          context, child, widget.parentData!);

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF8F8F8),
              title: const Text('تم إرسال رابط التحقق',
                  style: TextStyle(fontFamily: 'alfont')),
              content: const Text(
                  'تم إرسال رابط التحقق إلى بريدك الإلكتروني. الرجاء التحقق من بريدك.',
                  style: TextStyle(fontFamily: 'alfont')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => InitialPage()));
                  },
                  child: const Text('حسناً',
                      style: TextStyle(fontFamily: 'alfont')),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Custom text field with validation
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
        if (!arabicNameRegex.hasMatch(value))
          return 'الرجاء إدخال الاسم بالحروف العربية فقط';
        if (value.trim().isEmpty)
          return 'الاسم لا يمكن أن يكون فارغًا أو يحتوي على مسافات فقط';
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
      ),
      style: const TextStyle(fontFamily: 'alfont'),
    );
  }

  // Reusable dropdown field (for gender and age)
  Widget _buildDropdownField({
    required String hintText,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            hintText == 'العمر' ? _convertToArabicNumber(item) : item,
            style: const TextStyle(fontFamily: 'alfont', color: Colors.black),
          ),
        );
      }).toList(),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
      ),
      style: const TextStyle(fontFamily: 'alfont'),
      validator: validator,
    );
  }

  // Submit button
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
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context, widget.parentData),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'سجل طفلك الأول',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'alfont',
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Select image
                        GestureDetector(
                          onTap: () async {
                            final selectedPhoto = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectImageView()),
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
                                : const AssetImage(
                                    'assets/images/default_avatar.jpg'),
                            child: const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.edit, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Child name
                        _buildTextField(
                          hintText: 'اسم الطفل باللغة العربية',
                          controller: _nameController,
                          validator: (value) =>
                              value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\u0600-\u06FF\s]')),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Gender dropdown
                        _buildDropdownField(
                          hintText: 'الجنس',
                          items: ['ذكر', 'أنثى'],
                          value: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          validator: (value) =>
                              value == null ? 'هذا الحقل مطلوب' : null,
                        ),
                        const SizedBox(height: 15),
                        // Age dropdown
                        _buildDropdownField(
                          hintText: 'العمر',
                          items: _ageOptions.map((e) => e['value']!).toList(),
                          value: _selectedAge,
                          onChanged: (value) =>
                              setState(() => _selectedAge = value),
                          validator: (value) =>
                              value == null ? 'هذا الحقل مطلوب' : null,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontFamily: 'alfont',
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                        // Submit button
                        _buildButton(
                          text: 'تسجيل',
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
