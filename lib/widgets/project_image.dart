import 'dart:io';

import 'package:flutter/material.dart';

import 'cover_gradient.dart';

class ProjectImage extends StatelessWidget {
  const ProjectImage({
    super.key,
    this.imagePath,
    required this.seed,
    this.icon,
    this.fit = BoxFit.cover,
  });

  final String? imagePath;
  final String seed;
  final IconData? icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return Image.file(file, fit: fit);
      }
    }
    return CoverGradient(
      seed: seed,
      child: Center(
        child: Icon(
          icon ?? Icons.image_outlined,
          size: 44,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
