import 'package:flutter/material.dart';

import '../models/architect.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.architect, this.radius = 22});

  final Architect architect;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(architect.avatarColor).withValues(alpha: 0.15),
      child: Text(
        architect.name.isNotEmpty ? architect.name.characters.first : '؟',
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w800,
          color: Color(architect.avatarColor),
        ),
      ),
    );
  }
}
