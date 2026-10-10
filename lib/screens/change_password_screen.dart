// lib/screens/settings/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();

  bool loading = false;

  static const themeColor = Color(0xFF5E5B56);
  static const bgColor = Color(0xFFDBD7CF);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    currentCtrl.dispose();
    newCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      setState(() => loading = true);

      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentCtrl.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newCtrl.text.trim());
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully!")),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: themeColor),
        title: const Text(
          "Change Password",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _field("Current Password", currentCtrl),
                _field("New Password", newCtrl),
                const SizedBox(height: 25),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800], // professional grey
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Update & Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
