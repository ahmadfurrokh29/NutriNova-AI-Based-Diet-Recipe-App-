// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/theme_providers.dart'; // ThemeProvider import
import 'onboarding/profile_setup_screen.dart';
import 'change_password_screen.dart';
import 'about_app_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool notifications = true;
  bool loadingProfile = false; // Loading spinner when fetching profile

  static const themeColor = Color(0xFF5E5B56);
  static const bgColor = Color(0xFFDBD7CF);

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode; // <- getter in ThemeProvider

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: themeColor),
        title: const Text(
          "Settings",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _sectionTitle("Preferences"),
              _settingTile(
                icon: Icons.notifications_active_outlined,
                title: "Notifications",
                trailing: Switch(
                  value: notifications,
                  activeColor: themeColor,
                  onChanged: (v) => setState(() => notifications = v),
                ),
              ),
              _settingTile(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: themeColor,
                  onChanged: (v) {
                    themeProvider.toggle(v); // Toggle dark mode
                  },
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle("Account"),

              // Edit Profile
              _settingTile(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () async {
                  setState(() => loadingProfile = true);
                  // Navigate to ProfileSetupScreen in edit mode
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(isEdit: true),
                    ),
                  );
                  setState(() => loadingProfile = false);
                },
                trailing: loadingProfile
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right, color: Colors.grey),
              ),

              // Change Password
              _settingTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              _sectionTitle("Support"),

              _settingTile(
                icon: Icons.help_outline,
                title: "Help Center",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  );
                },
              ),
              _settingTile(
                icon: Icons.info_outline,
                title: "About App",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                  );
                },
              ),

              const SizedBox(height: 30),
              _logoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // WIDGETS
  // =========================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: themeColor,
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: themeColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        "Logout",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
