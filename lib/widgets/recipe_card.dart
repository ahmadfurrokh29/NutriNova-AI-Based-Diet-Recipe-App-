// lib/widgets/recipe_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final String image;
  final String name;
  final String time;
  final String calories;
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.image,
    required this.name,
    required this.time,
    required this.calories,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: 220,
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // IMAGE
                Image.network(
                  widget.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                ),

                // GRADIENT OVERLAY
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // GLASS EFFECT PANEL
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.time,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 14,
                                  color: Colors.orangeAccent,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.calories,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
