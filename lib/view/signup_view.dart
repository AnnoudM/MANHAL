import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/signup_controller.dart';
import '../model/signup_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/child_info_view.dart';

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
  String? _emailError;

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
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
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
                        const SizedBox(height: 50),
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
                        _buildNameField(
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
                            final arabicCharRegex = RegExp(r'[\u0600-\u06FF]');
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            } else if (arabicCharRegex.hasMatch(value)) {
                              return 'لا يسمح باستخدام الأحرف العربية في البريد الإلكتروني';
                            } else if (!value.contains('@')) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            } else if (_emailError != null) {
                              return _emailError;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (_emailError != null) {
                              setState(() {
                                _emailError = null;
                              });
                              _formKey.currentState!.validate();
                            }
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
                            }
                            if (value.length < 8) {
                              return 'يجب أن تتكون كلمة المرور من 8 خانات على الأقل';
                            }

                            bool hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
                            bool hasNumber = value.contains(RegExp(r'[0-9]'));
                            bool hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                            if (!(hasLetter && hasNumber) && !(hasLetter && hasSymbol) && !(hasNumber && hasSymbol)) {
                              return 'كلمة المرور لا تطابق الشروط المطلوبة!';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 5),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'يجب أن تحتوي كلمة المرور على 8 خانات على الأقل وتتضمن أحرف وأرقام.',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'alfont'),
                            textAlign: TextAlign.right,
                          ),
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
                            if (controller.passwordController.text.isNotEmpty) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى تأكيد كلمة المرور';
                              } else if (value != controller.passwordController.text) {
                                return 'كلمتا المرور غير متطابقتين';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildButton(
                          text: 'متابعة',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _emailError = null;
                              });

                              try {
                                bool emailExists = await controller.isEmailRegistered(controller.emailController.text);

                                if (emailExists) {
                                  setState(() {
                                    _emailError = 'هذا البريد الإلكتروني مسجل مسبقاً!';
                                  });
                                  _formKey.currentState!.validate();
                                  return;
                                }

                                SignUpModel parentData = SignUpModel(
                                  name: controller.nameController.text,
                                  email: controller.emailController.text,
                                  password: controller.passwordController.text,
                                );

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChildInfoView(
                                        parentData: parentData,
                                        parentId: '',
                                        childId: '',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('حدث خطأ أثناء التحقق من البريد: $e', style: TextStyle(fontFamily: 'alfont')),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
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
          ],
        ),
      ),
    );
  }

 _buildNameField({
  required String hintText,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'يرجى إدخال الاسم';
      }
      // التحقق إذا كان الاسم يحتوي فقط على مسافات أو أرقام
      if (value.trim().isEmpty) {
        return 'الاسم لا يمكن أن يكون فارغًا أو يحتوي على مسافات فقط';
      }
      // التحقق من أن الاسم يحتوي فقط على الحروف العربية (بدون أرقام)
      final arabicNameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
      // التحقق من وجود أرقام عربية (١٢٣٤) أو إنجليزية (1234)
      final hasNumbers = RegExp(r'[0-9\u0660-\u0669]').hasMatch(value); // هذه تشمل الأرقام العربية (٠-٩)
      if (hasNumbers) {
        return 'الاسم لا يمكن أن يحتوي على أرقام';
      }
      if (!arabicNameRegex.hasMatch(value)) {
        return 'الرجاء إدخال الاسم بالحروف العربية فقط';
      }
      return null;
    },
    textDirection: TextDirection.rtl,
    keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')), // السماح فقط بالحروف العربية والمسافات
    ],
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
  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
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
        errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
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
