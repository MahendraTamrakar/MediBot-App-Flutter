import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidCircularGradient extends StatefulWidget {
  /// The diameter of the circular container.
  final double size;

  const LiquidCircularGradient({
    super.key,
    this.size = 200.0,
  });

  @override
  State<LiquidCircularGradient> createState() => _LiquidCircularGradientState();
}

class _LiquidCircularGradientState extends State<LiquidCircularGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // This controller drives the continuous rotation.
    // A duration of 5-8 seconds creates a slow, syrupy flow.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(); // Repeat indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The base dark color for the background of the liquid
    const Color baseColor = Color(0xFF0A0E14);

    return Center(
      // ClipOval ensures everything outside the circle is cut off
      child: ClipOval(
        child: Container(
          width: widget.size,
          height: widget.size,
          color: baseColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // LAYER 1: Deep base flow (Slow, clockwise)
              _buildRotatingBlob(
                colors: [Colors.teal.shade900, Colors.blue.shade800],
                speedMultiplier: 1.0,
                // Slight offset creates the "wobble"
                offset: const Offset(-0.15, -0.1),
                scale: 1.5, // Must be larger than the container
              ),

              // LAYER 2: Middle mixing layer (Medium speed, counter-clockwise)
              _buildRotatingBlob(
                colors: [
                  Colors.purple.shade600.withOpacity(0.8),
                  Colors.deepPurple.shade900.withOpacity(0.5)
                ],
                speedMultiplier: -1.7, // Negative speed for opposite rotation
                offset: const Offset(0.1, 0.2),
                scale: 1.6,
              ),

              // LAYER 3: Brighter highlights (Fastest, clockwise)
              _buildRotatingBlob(
                colors: [
                  Colors.cyanAccent.withOpacity(0.5),
                  Colors.transparent
                ],
                speedMultiplier: 2.5,
                offset: const Offset(0.05, -0.25),
                scale: 1.7,
              ),

              // Optional Overlay: Adds a slight radial shadow to make it look spherical
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.transparent,
                      baseColor.withOpacity(0.5),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotatingBlob({
    required List<Color> colors,
    required double speedMultiplier,
    required Offset offset,
    required double scale,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          // Apply the slight offset to center of rotation
          offset: Offset(
            widget.size * offset.dx,
            widget.size * offset.dy,
          ),
          child: Transform.rotate(
            // Rotate based on controller value * speed * 2pi (full circle)
            angle: _controller.value * speedMultiplier * 2 * math.pi,
            child: Container(
              // Make the blob significantly larger than the view port
              width: widget.size * scale,
              height: widget.size * scale,
              decoration: BoxDecoration(
                // Using a rounded rectangle instead of a perfect circle
                // adds to the irregular "blob" shape when rotated.
                borderRadius: BorderRadius.circular(widget.size * scale / 3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}