import 'package:flutter/material.dart';
import '../controller/signup_controller.dart';
import '../model/child_model.dart';

class ChildInfoView extends StatefulWidget {
  final String parentId;

  ChildInfoView({required this.parentId});

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
      Child child = Child(
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        age: _age!,
      );
      await _controller.addChild(widget.parentId, child);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل الطفل بنجاح')),
      );
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('سجل طفلك الأول')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'اسم الطفل'),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['ذكر', 'أنثى'].map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                )).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: InputDecoration(labelText: 'الجنس'),
                validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'العمر'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _age = int.tryParse(value),
                validator: (value) => (value == null || int.tryParse(value) == null) ? 'يرجى إدخال عمر صحيح' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}