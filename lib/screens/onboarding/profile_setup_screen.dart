// lib/screens/onboarding/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/cuisine_chip.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEdit;
  const ProfileSetupScreen({Key? key, this.isEdit = false}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _age = TextEditingController();

  // Metric
  final _heightCm = TextEditingController();
  final _weightKg = TextEditingController();

  // Imperial
  final _heightFeet = TextEditingController();
  final _heightInch = TextEditingController();
  final _weightLbs = TextEditingController();

  String activity = 'moderate';
  String goal = 'maintain';
  String gender = 'female';
  bool isMetric = true;
  bool saving = false;

  List<String> cuisines = [
    'Pakistani',
    'Indian',
    'Chinese',
    'Turkish',
    'Italian',
    'Continental',
  ];
  Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => saving = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      setState(() {
        _age.text = (data['age'] ?? '').toString();
        gender = (data['gender'] ?? 'female').toString();
        activity = (data['activity'] ?? 'moderate').toString();
        goal = (data['goal'] ?? 'maintain').toString();
        selected = Set<String>.from(data['cuisines'] ?? []);

        String unit = (data['unit'] ?? 'metric').toString();
        isMetric = unit == 'metric';

        if (isMetric) {
          _heightCm.text = (data['height_m'] != null)
              ? (data['height_m'] * 100).toStringAsFixed(0)
              : '';
          _weightKg.text = data['weight_kg']?.toStringAsFixed(1) ?? '';
        } else {
          double heightInches = (data['height_m'] ?? 0) / 0.0254;
          _heightFeet.text = (heightInches ~/ 12).toString();
          _heightInch.text = (heightInches % 12).toStringAsFixed(0);
          _weightLbs.text = ((data['weight_kg'] ?? 0) / 0.453592)
              .toStringAsFixed(1);
        }
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch user data")),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  double _heightMeters() {
    if (isMetric) {
      return double.tryParse(_heightCm.text) != null
          ? double.parse(_heightCm.text) / 100
          : 0;
    } else {
      int ft = int.tryParse(_heightFeet.text) ?? 0;
      int inch = int.tryParse(_heightInch.text) ?? 0;
      int totalInches = ft * 12 + inch;
      return totalInches * 0.0254;
    }
  }

  double _weightKgValue() {
    if (isMetric) {
      return double.tryParse(_weightKg.text) ?? 0;
    } else {
      return (double.tryParse(_weightLbs.text) ?? 0) * 0.453592;
    }
  }

  double _calculateBMI() {
    final h = _heightMeters();
    final w = _weightKgValue();
    if (h == 0) return 0;
    return w / (h * h);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _saveProfile() async {
    if (_age.text.isEmpty ||
        (isMetric && (_heightCm.text.isEmpty || _weightKg.text.isEmpty)) ||
        (!isMetric &&
            (_heightFeet.text.isEmpty ||
                _heightInch.text.isEmpty ||
                _weightLbs.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => saving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      double heightM = _heightMeters();
      double weightKg = _weightKgValue();
      double bmi = _calculateBMI();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'age': int.parse(_age.text),
        'gender': gender,
        'activity': activity,
        'goal': goal,
        'cuisines': selected.toList(),
        'height_m': double.parse(heightM.toStringAsFixed(2)),
        'weight_kg': double.parse(weightKg.toStringAsFixed(1)),
        'bmi': double.parse(bmi.toStringAsFixed(2)),
        'bmi_category': _bmiCategory(bmi),
        'unit': isMetric ? 'metric' : 'imperial',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      if (!widget.isEdit) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pop(context); // go back to Settings
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save profile")));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/NutriNova.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          "Tell us about you",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Gender",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _genderChip("Female"),
                            const SizedBox(width: 10),
                            _genderChip("Male"),
                            const SizedBox(width: 10),
                            _genderChip("Other"),
                          ],
                        ),
                        const SizedBox(height: 18),

                        _inputField("Age", _age, "years"),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text("Metric"),
                              selected: isMetric,
                              onSelected: (_) =>
                                  setState(() => isMetric = true),
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text("Imperial"),
                              selected: !isMetric,
                              onSelected: (_) =>
                                  setState(() => isMetric = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        isMetric ? _metricFields() : _imperialFields(),
                        const SizedBox(height: 18),

                        const Text(
                          "Activity",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        _dropdown(),
                        const SizedBox(height: 18),

                        const Text(
                          "Goal",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: [
                            _goalChip("Lose", "lose"),
                            _goalChip("Maintain", "maintain"),
                            _goalChip("Gain", "gain"),
                          ],
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          "Preferred cuisines",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cuisines.map((c) {
                            return CuisineChip(
                              label: c,
                              selected: selected.contains(c),
                              onTap: () {
                                setState(() {
                                  selected.contains(c)
                                      ? selected.remove(c)
                                      : selected.add(c);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 25),

                        saving
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                label: widget.isEdit
                                    ? "Save Changes"
                                    : "Continue",
                                onTap: _saveProfile,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricFields() => Row(
    children: [
      Expanded(child: _inputField("Height", _heightCm, "cm")),
      const SizedBox(width: 12),
      Expanded(child: _inputField("Weight", _weightKg, "kg")),
    ],
  );

  Widget _imperialFields() => Row(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(child: _inputField("Height", _heightFeet, "ft")),
            const SizedBox(width: 6),
            Expanded(child: _inputField("Height", _heightInch, "in")),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: _inputField("Weight", _weightLbs, "lbs")),
    ],
  );

  Widget _inputField(
    String label,
    TextEditingController controller,
    String unit,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixText: unit,
        suffixStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _genderChip(String g) => ChoiceChip(
    label: Text(g),
    selected: gender == g.toLowerCase(),
    onSelected: (_) => setState(() => gender = g.toLowerCase()),
  );
  Widget _dropdown() => DropdownButton<String>(
    value: activity,
    dropdownColor: Colors.black,
    isExpanded: true,
    iconEnabledColor: Colors.white,

    // 👇 ye selected text ka final control hai
    selectedItemBuilder: (BuildContext context) {
      return ['sedentary', 'light', 'moderate', 'active']
          .map(
            (e) => Text(
              e,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
          .toList();
    },

    style: const TextStyle(color: Colors.white, fontSize: 16),

    items: ['sedentary', 'light', 'moderate', 'active']
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        )
        .toList(),

    onChanged: (v) => setState(() => activity = v!),
  );

  Widget _goalChip(String label, String value) => ChoiceChip(
    label: Text(label),
    selected: goal == value,
    onSelected: (_) => setState(() => goal = value),
  );
}
