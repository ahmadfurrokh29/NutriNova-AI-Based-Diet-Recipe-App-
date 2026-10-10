import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
//import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'profile_screen.dart'; // NEW PROFILE SCREEN

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const profile = '/profile'; // NEW PROFILE ROUTE
  static const home = '/home';
  static const grocery = '/grocery';
  static const settings = '/settings';
  static const recipeDetail = '/recipeDetail';

  // ===============================
  // ROUTES MAP
  // ===============================
  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashScreen(),
    login: (_) => const SaladLoginScreen(),
    signup: (_) => const SaladSignupScreen(),
    profile: (_) => const ProfileScreen(), // UPDATED TO NEW PROFILE SCREEN
    home: (_) => const HomeScreen(),
    settings: (_) => const SettingsScreen(),
    // grocery: (_) => GroceryScreen(),
  };

  // ===============================
  // ON GENERATE ROUTE (dynamic routes)
  // ===============================
  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case recipeDetail:
        final recipe = settings.arguments as Map<String, dynamic>?;

        if (recipe == null) {
          // fallback if arguments missing
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }

        return MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe),
        );
    }

    // fallback for unknown routes
    return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}
