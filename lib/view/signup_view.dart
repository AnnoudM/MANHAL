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
  final controller = SignUpController(); // controller to access form data
  final _formKey = GlobalKey<FormState>(); // form key for validation
  bool _obscurePassword = true; // toggle password visibility
  bool _obscureConfirmPassword = true; // toggle confirm password visibility
  String? _emailError;
  String? _passwordLengthError;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // for Arabic layout
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BackGroundManhal.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // back button
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // form content
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
                        // name field (Arabic only)
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
                        // email field with validation
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
                        // password field with custom rules
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
                            if (value.length > 15) {
                              return 'يجب ألا تزيد كلمة المرور عن 15 خانة';
                            }
                            bool hasLetter = value.contains(RegExp(r'[a-zA-Z]'));
                            bool hasNumber = value.contains(RegExp(r'[0-9]'));
                            bool hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                            if (!(hasLetter && hasNumber && hasSymbol)) {
                              return 'يجب أن تحتوي كلمة المرور على حرف واحد على الأقل، ورقم، ورمز';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _passwordLengthError = value.length > 15
                                  ? 'يجب ألا تزيد كلمة المرور عن ١٥ خانة'
                                  : null;
                            });
                          },
                          errorText: _passwordLengthError,
                        ),
                        const SizedBox(height: 5),
                        // password instructions
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'يجب أن تحتوي كلمة المرور على ٨-١٥ خانة وتشمل حرف، رقم، ورمز.',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'alfont'),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // confirm password field
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
                        // continue button
                        _buildButton(
                          text: 'متابعة',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _emailError = null;
                              });

                              try {
                                // check if email is already registered
                                bool emailExists = await controller.isEmailRegistered(controller.emailController.text);

                                if (emailExists) {
                                  setState(() {
                                    _emailError = 'هذا البريد الإلكتروني مسجل مسبقاً!';
                                  });
                                  _formKey.currentState!.validate();
                                  return;
                                }

                                // create sign up model and go to child info screen
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
                        // already have account? login here
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

  // name field (Arabic only)
  _buildNameField({
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

  // reusable text field (used for email)
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

  // reusable password field with visibility toggle
  Widget _buildPasswordField({
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      maxLength: 15,
      maxLengthEnforcement: MaxLengthEnforcement.none,
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
        errorText: errorText,
        errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
        counterText: '',
      ),
      style: const TextStyle(fontFamily: 'alfont'),
    );
  }

  // custom button widget
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
