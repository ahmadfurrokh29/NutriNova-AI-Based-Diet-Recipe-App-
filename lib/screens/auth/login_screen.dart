import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes.dart';

class SaladLoginScreen extends StatefulWidget {
  const SaladLoginScreen({super.key});

  @override
  State<SaladLoginScreen> createState() => _SaladLoginScreenState();
}

class _SaladLoginScreenState extends State<SaladLoginScreen> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const Color cream = Color(0xFFFFF7F0);
  static const Color grey = Color(0xFF5E5B56);

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Email must contain @';
    }
    return null;
  }

  // ========================
  // Firebase Login Function
  // ========================
  void loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      Navigator.pop(context); // Close loading

      // Check if user profile exists in Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.profile);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Top background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: Image.asset(
              'assets/images/salad_header.jfif',
              fit: BoxFit.cover,
            ),
          ),

          // Middle cream section
          Positioned(
            top: screenHeight * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: cream,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3426),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Log in to see your healthy meal plans',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7E6556),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email field
                      _buildInputField(
                        controller: emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      _buildInputField(
                        controller: passController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: grey,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Signup Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Color(0xFF7E6556)),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.signup),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF4A3426),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable input builder
  static Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
