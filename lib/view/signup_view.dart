import 'package:flutter/material.dart';
import '../controller/signup_controller.dart';
import '../model/signup_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final controller = SignUpController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
            onPressed: () => Navigator.pop(context),
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
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'alfont',
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      hintText: 'الاسم باللغة العربية',
                      controller: controller.nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      hintText: 'البريد الإلكتروني',
                      controller: controller.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        } else if (!value.contains('@')) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      hintText: 'كلمة المرور',
                      controller: controller.passwordController,
                      obscureText: _obscurePassword,
                      toggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        } else if (value.length < 6) {
                          return 'كلمة المرور لم تحقق الشروط المطلوبة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل وتتضمن حروف وأرقام.',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'alfont'),
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      hintText: 'تأكيد كلمة المرور',
                      controller: controller.confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      toggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى تأكيد كلمة المرور';
                        } else if (value != controller.passwordController.text) {
                          return 'كلمتا المرور غير متطابقتين';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                   _buildButton(
  text: 'متابعة',
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      // تحقق من وجود البريد الإلكتروني
      bool emailExists = await controller.isEmailRegistered(controller.emailController.text);

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('هذا البريد الإلكتروني مسجل مسبقاً.', style: TextStyle(fontFamily: 'alfont'))),
        );
      } else {
        await controller.saveParentDataTemp(SignUpModel(
          name: controller.nameController.text,
          email: controller.emailController.text,
          password: controller.passwordController.text,
        ));
        controller.proceedToChildInfo(context);
      }
    }
  },
),

                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('لديك حساب بالفعل؟ ', style: TextStyle(fontFamily: 'alfont')),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const Text(
                            'سجل هنا',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontFamily: 'alfont',
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
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
      ),
      style: const TextStyle(fontFamily: 'alfont'),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
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
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      style: const TextStyle(fontFamily: 'alfont'),
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
}
