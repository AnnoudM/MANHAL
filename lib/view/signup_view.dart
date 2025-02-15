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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // إضافة الخلفية هنا
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BackGroundManhal.jpg'),
                  fit: BoxFit.cover,
                ),
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
  if (value.length < 6) {
    return 'يجب أن تتكون كلمة المرور من 6 خانات على الأقل';
  }

  bool hasLetter = value.contains(RegExp(r'[a-zA-Z]')); // التحقق من وجود حروف
  bool hasNumber = value.contains(RegExp(r'[0-9]')); // التحقق من وجود أرقام
  bool hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // التحقق من وجود رموز

  // يجب أن تحتوي كلمة المرور على (حروف + أرقام) أو (حروف + رموز) أو (أرقام + رموز)
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
                            'يجب أن تحتوي كلمة المرور على 6 خانات على الأقل وتتضمن أحرف وأرقام.',
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
    if (_formKey.currentState!.validate()) { // ✅ التحقق من صحة جميع المدخلات
      setState(() {
        _emailError = null; // ✅ إعادة تعيين خطأ البريد الإلكتروني إن وجد
      });

      try {
        bool emailExists = await controller.isEmailRegistered(controller.emailController.text);

        if (emailExists) {
          setState(() {
            _emailError = 'هذا البريد الإلكتروني مسجل مسبقاً!';
          });
          _formKey.currentState!.validate(); // ✅ تحديث الشاشة لإظهار الخطأ
          return; // ❌ لا تكمل التنفيذ إذا كان البريد الإلكتروني مسجلاً بالفعل
        }

        // ✅ عدم حفظ البيانات الآن، فقط تخزينها مؤقتًا للانتقال لصفحة الطفل
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
                parentData: parentData, // ✅ تمرير بيانات الوالد بدون حفظها بعد
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

  Widget _buildNameField({
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textDirection: TextDirection.rtl,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
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
