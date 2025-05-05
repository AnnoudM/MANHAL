import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controller/Login_controller.dart';
import '../view/ChildListView.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _errorMessage;

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
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Form content
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
                        const SizedBox(height: 60),
                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'alfont',
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Email field
                        _buildTextField(
                          hintText: 'البريد الالكتروني',
                          controller: _controller.emailController,
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
                        // Password field
                        _buildTextField(
                          hintText: 'كلمة المرور',
                          controller: _controller.passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        // Error message
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
                        const SizedBox(height: 20),
                        // Submit button
                        _buildButton(
                          text: 'تسجيل',
                          onPressed: () async {
                            final connectivityResult = await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              setState(() {
                                _errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
                              });
                              return;
                            }

                            if (_formKey.currentState!.validate()) {
                              final result = await _controller.loginUser(
                                email: _controller.emailController.text,
                                password: _controller.passwordController.text,
                              );
                              if (result != null) {
                                setState(() {
                                  _errorMessage = result;
                                });
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChildListView(),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        // Sign up text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'alfont')),
                            GestureDetector(
                              onTap: () => _controller.navigateToSignUp(context),
                              child: const Text(
                                'سجل الآن',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'alfont',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Forgot password button
                        TextButton(
                          onPressed: () async {
                            if (_controller.emailController.text.isEmpty) {
                              setState(() {
                                _errorMessage = 'يرجى إدخال البريد الإلكتروني لإعادة تعيين كلمة المرور';
                              });
                            } else {
                              setState(() {
                                _errorMessage = null;
                              });
                              await _controller.resetPassword(
                                _controller.emailController.text,
                                context,
                              );
                            }
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                              fontFamily: 'alfont',
                            ),
                          ),
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

  // Custom input field
  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'alfont'),
        errorStyle: const TextStyle(
          fontFamily: 'alfont',
          color: Colors.red,
        ),
        filled: true,
        fillColor: const Color(0xFFFFF5CC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(fontFamily: 'alfont'),
    );
  }

  // Reusable styled button
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
