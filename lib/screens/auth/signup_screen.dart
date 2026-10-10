//lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../routes.dart'; // Uncomment if you use Routes class

class SaladSignupScreen extends StatefulWidget {
  const SaladSignupScreen({super.key});

  @override
  State<SaladSignupScreen> createState() => _SaladSignupScreenState();
}

class _SaladSignupScreenState extends State<SaladSignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const Color cream = Color(0xFFFFF7F0);
  static const Color grey = Color(0xFF5E5B56);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter an email';
    if (!value.contains('@')) return 'Email must contain @';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passController.text) return 'Passwords do not match';
    return null;
  }

  // =========================
  // Firebase Signup Function
  // =========================
  void signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Create user in Firebase Auth
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      // Save basic info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      Navigator.pop(context); // close loading

      // Navigate to profile setup screen
      Navigator.pushReplacementNamed(
        context,
        '/profile_setup',
      ); // replace with Routes.profile
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3426),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign up to start your personalized meal plan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7E6556),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Name
                      _buildInputField(
                        controller: nameController,
                        hint: 'Full Name',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildInputField(
                        controller: emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildInputField(
                        controller: passController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildInputField(
                        controller: confirmPassController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 24),

                      // Signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signupUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: grey,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Color(0xFF7E6556)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/login',
                            ), // replace with Routes.login
                            child: const Text(
                              'Login',
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

  // Input field builder
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
