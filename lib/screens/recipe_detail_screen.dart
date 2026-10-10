//lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe['ingredients'] as List<dynamic>? ?? [];
    final directions = recipe['directions'] as List<dynamic>? ?? [];
    final description = recipe['description'] ?? 'No description available.';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(190, 205, 157, 75),
        title: Text(
          recipe['name'] ?? 'Recipe',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== IMAGE WITH LOADING & FALLBACK ======
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child: Image.network(
              recipe['image'] ?? '',
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 260,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  recipe['fallbackImage'] ?? '',
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 260,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 40),
                    );
                  },
                );
              },
            ),
          ),

          // ====== DETAILS ======
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      recipe['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B3D2F),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ====== STATS ROW ======
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStat(
                              Icons.schedule,
                              recipe['time']?.toString() ?? '—',
                            ),
                            const SizedBox(width: 20),
                            _buildStat(
                              Icons.list_alt,
                              "${ingredients.length} item${ingredients.length != 1 ? 's' : ''}",
                            ),
                            const SizedBox(width: 20),
                            _buildStat(
                              Icons.local_fire_department,
                              recipe['calories']?.toString() ?? '—',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ingredients
                    if (ingredients.isNotEmpty) ...[
                      const Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B3D2F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...ingredients.map((ing) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFC49349),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ing.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4B3D2F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // Directions
                    if (directions.isNotEmpty) ...[
                      const Text(
                        "Directions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B3D2F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...directions.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final step = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$index.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B3D2F),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4B3D2F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== STAT WIDGET ======
  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC49349)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B3D2F),
          ),
        ),
      ],
    );
  }
}
