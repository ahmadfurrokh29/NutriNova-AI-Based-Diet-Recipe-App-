import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  static const themeColor = Color(0xFF5E5B56);
  static const bgColor = Color(0xFFDBD7CF);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final List<String> helpItems = [
    "Check your internet connection.",
    "Re-login if data is not loading.",
    "Contact admin for assistance.",
    "Ensure app is updated to latest version.",
    "Clear cache if app behaves unexpectedly.",
  ];

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
          "Help Center",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: helpItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _helpCard(helpItems[index], index);
            },
          ),
        ),
      ),
    );
  }

  Widget _helpCard(String text, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(Icons.help_outline, color: themeColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
