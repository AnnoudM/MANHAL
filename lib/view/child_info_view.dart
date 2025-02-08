import 'package:flutter/material.dart';
import '../controller/signup_controller.dart';
import '../model/child_model.dart';
import '../model/signup_model.dart';

class ChildInfoView extends StatefulWidget {
  final SignUpModel parentData;
  ChildInfoView({required this.parentData});

  @override
  _ChildInfoViewState createState() => _ChildInfoViewState();
}

class _ChildInfoViewState extends State<ChildInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGender;
  int? _age;

  final SignUpController _controller = SignUpController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String? parentId = await _controller.registerParent(widget.parentData);

      if (parentId != null && parentId.length > 5) {
        await _controller.saveParentData(parentId, widget.parentData);

        Child child = Child(
          name: _nameController.text.trim(),
          gender: _selectedGender!,
          age: _age!,
        );
        await _controller.addChild(parentId, child);
        await _controller.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني.')),
        );

        _controller.checkEmailVerification(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تسجيل الحساب.')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFFFF5CC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
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
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFFFF5CC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, widget.parentData);
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'سجل طفلك الأول',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      hintText: 'اسم الطفل',
                      controller: _nameController,
                      validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
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
                    ),
                    const SizedBox(height: 30),
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
      ),
    );
  }
}
