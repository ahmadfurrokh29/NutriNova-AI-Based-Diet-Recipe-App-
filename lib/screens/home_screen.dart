// lib/screens/home_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'settings_screen.dart';
import '../profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const themeColor = Color(0xFF5E5B56);
  static const bgColor = Color(0xFFDBD7CF);

  String userName = 'User';
  double bmi = 0.0;
  List<String> userCuisines = [];
  List<Map<String, dynamic>> recipes = [];
  bool loading = true;

  late GenerativeModel model;

  // Navbar animation controller
  late AnimationController _navController;
  late Animation<double> _navScaleAnimation;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );

    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _navController, curve: Curves.easeInOutBack),
    );

    _fetchUserData();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  // ==========================
  // FETCH USER DATA
  // ==========================
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      setState(() {
        userName = doc['name'] ?? user.email ?? 'User';
        bmi = (doc['bmi'] ?? 0).toDouble();
        userCuisines = List<String>.from(doc['cuisines'] ?? []);
      });

      if (userCuisines.isNotEmpty) {
        await _fetchRecipes(userCuisines);
      }

      setState(() => loading = false);
    } catch (e) {
      debugPrint("User fetch error: $e");
      setState(() => loading = false);
    }
  }

  // ==========================
  // FETCH RECIPES
  // ==========================
  Future<void> _fetchRecipes(List<String> cuisines) async {
    try {
      final prompt =
          """
Generate 3 recipes for each cuisine: ${cuisines.join(", ")}.
Return ONLY valid JSON. No markdown. No backticks.

Format:
{
 "Italian": [
   {
     "name": "Spaghetti Carbonara",
     "calories": "450 kcal",
     "time": "20 min",
     "description": "Classic Italian pasta",
     "ingredients": ["Pasta", "Eggs"],
     "directions": ["Cook pasta", "Mix sauce"]
   }
 ]
}
""";

      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text == null) return;

      String raw = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(raw);

      List<Map<String, dynamic>> temp = [];
      for (var entry in data.entries) {
        for (var item in entry.value) {
          final recipe = Map<String, dynamic>.from(item);
          recipe['cuisine'] = entry.key;
          recipe['id'] = recipe['name'];
          recipe['image'] = await _fetchImage(recipe['name']);
          temp.add(recipe);
        }
      }

      setState(() => recipes = temp);
    } catch (e) {
      debugPrint("Recipe error: $e");
    }
  }

  // ==========================
  // FETCH IMAGE
  // ==========================
  Future<String> _fetchImage(String name) async {
    try {
      final url = Uri.https('pixabay.com', '/api/', {
        'key': dotenv.env['PIXABAY_API_KEY'] ?? '',
        'q': '$name food',
        'image_type': 'photo',
        'per_page': '3',
        'safesearch': 'true',
      });
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          return data['hits'][0]['webformatURL'];
        }
      }
    } catch (_) {}
    return "https://placehold.co/600x400/png?text=${Uri.encodeComponent(name)}";
  }

  // ==========================
  // BMI HELPERS
  // ==========================
  String getBmiStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.redAccent;
    return Colors.red;
  }

  // ==========================
  // UI
  // ==========================
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
      bottomNavigationBar: _buildAnimatedNavBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              "Hello, $userName",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 16),
            if (bmi > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "BMI: ${bmi.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bmiColor(bmi).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getBmiStatus(bmi),
                        style: TextStyle(
                          color: bmiColor(bmi),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ...userCuisines.map((cuisine) {
              final list = recipes
                  .where((r) => r['cuisine'] == cuisine)
                  .toList();
              if (list.isEmpty) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuisine,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final recipe = list[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: RecipeCard(
                            image: recipe['image'],
                            name: recipe['name'],
                            calories: recipe['calories'],
                            time: recipe['time'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ==========================
  // NAVBAR
  // ==========================
  Widget _buildAnimatedNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", true),
          _navItem(
            Icons.settings,
            "Settings",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _navItem(
            Icons.person,
            "Profile",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _navController.forward().then((_) => _navController.reverse());
        if (onTap != null) onTap();
      },
      child: ScaleTransition(
        scale: _navScaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? themeColor : Colors.grey),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? themeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
