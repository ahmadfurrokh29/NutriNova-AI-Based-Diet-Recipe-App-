//lib/widgets/primary_button.dart

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  const PrimaryButton({
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
