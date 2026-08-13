import 'package:flutter/material.dart';

const _gradients = [
  [Color(0xFF0F766E), Color(0xFF2DD4BF)],
  [Color(0xFF4338CA), Color(0xFF818CF8)],
  [Color(0xFF9A3412), Color(0xFFFB923C)],
  [Color(0xFF0E7490), Color(0xFF38BDF8)],
  [Color(0xFF7C3AED), Color(0xFFC4B5FD)],
  [Color(0xFF065F46), Color(0xFF34D399)],
  [Color(0xFF991B1B), Color(0xFFF87171)],
];

class CoverGradient extends StatelessWidget {
  const CoverGradient({super.key, required this.seed, required this.child});

  final String seed;
  final Widget child;

  static Color colorOf(String seed) => _gradients[seed.hashCode.abs() % _gradients.length][0];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[seed.hashCode.abs() % _gradients.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.map((c) => c.withValues(alpha: 0.9)).toList(),
        ),
      ),
      child: child,
    );
  }
}
