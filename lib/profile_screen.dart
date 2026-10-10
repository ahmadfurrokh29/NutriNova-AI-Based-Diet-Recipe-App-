import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color themeColor = Color(0xFF5E5B56);
const Color bgColor = Color(0xFFDBD7CF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String userName = '';
  String email = '';
  double bmi = 0.0;
  String age = '';
  String gender = '';
  bool loading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fetchUserData();
    _controller.forward();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      setState(() {
        userName = doc['name']?.toString() ?? user.email ?? '';
        email = user.email ?? '';
        bmi = doc['bmi'] != null
            ? double.tryParse(doc['bmi'].toString()) ?? 0.0
            : 0.0;
        age = doc['age']?.toString() ?? 'N/A';
        gender = doc['gender']?.toString() ?? 'N/A';
        loading = false;
      });
    } catch (e) {
      debugPrint("Profile fetch error: $e");
      setState(() => loading = false);
    }
  }

  String getBmiStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange.shade700;
    if (bmi < 25) return Colors.brown.shade600;
    if (bmi < 30) return Colors.brown.shade800;
    return Colors.brown.shade900;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: themeColor)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: themeColor),
        title: const Text(
          "Profile",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== CONSTANT AVATAR =====
              CircleAvatar(
                radius: 60,
                backgroundColor: themeColor.withOpacity(0.2),
                child: const Icon(Icons.person, size: 60, color: themeColor),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // ===== USER INFO CARDS =====
              _infoCard(
                "BMI",
                bmi.toStringAsFixed(1),
                getBmiStatus(bmi),
                bmiColor(bmi),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7B5E57).withOpacity(0.85),
                    const Color(0xFFD1BFA3).withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              _infoCard(
                "Age",
                age,
                "",
                const Color(0xFF6D4C41),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFBCAAA4).withOpacity(0.6),
                    const Color(0xFFD7CCC8).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              _infoCard(
                "Gender",
                gender,
                "",
                const Color(0xFF5D4037),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8D6E63).withOpacity(0.7),
                    const Color(0xFFD7CCC8).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    String value,
    String subtitle,
    Color color, {
    Gradient? gradient,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        color: gradient == null ? Colors.white.withOpacity(0.25) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
