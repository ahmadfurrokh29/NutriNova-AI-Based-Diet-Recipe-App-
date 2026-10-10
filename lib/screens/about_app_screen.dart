// lib/screens/settings/about_app_screen.dart

import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with SingleTickerProviderStateMixin {
  static const themeColor = Color(0xFF5E5B56);
  static const bgColor = Color(0xFFDBD7CF);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final List<Map<String, dynamic>> infoItems = [
    {
      "icon": Icons.restaurant_menu,
      "title": "AI Recipes",
      "desc":
          "Get AI-based recipe recommendations based on your BMI, lifestyle, and preferences.",
    },
    {
      "icon": Icons.flutter_dash,
      "title": "Built with Flutter",
      "desc":
          "Cross-platform UI built with Flutter for smooth and responsive design.",
    },
    {
      "icon": Icons.cloud,
      "title": "Powered by Firebase",
      "desc":
          "Realtime database, authentication, and storage powered by Firebase.",
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          "About App",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: infoItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _infoCard(
                icon: infoItems[index]["icon"],
                title: infoItems[index]["title"],
                description: infoItems[index]["desc"],
                index: index,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required int index,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeColor, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
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
