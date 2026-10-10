//lib/widgets/cuisine_chip.dart

import 'package:flutter/material.dart';

class CuisineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CuisineChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      elevation: 2,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
