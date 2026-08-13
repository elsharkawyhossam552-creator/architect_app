import 'package:flutter/material.dart';

import '../models/client_project.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.onTap});

  final ProjectStatus status;
  final VoidCallback? onTap;

  static Color colorOf(ProjectStatus status) => switch (status) {
        ProjectStatus.inquiry => const Color(0xFF6B7280),
        ProjectStatus.initial => const Color(0xFF2563EB),
        ProjectStatus.approved => const Color(0xFF7C3AED),
        ProjectStatus.execution => const Color(0xFFD97706),
        ProjectStatus.review => const Color(0xFF0EA5E9),
        ProjectStatus.delivered => const Color(0xFF16A34A),
      };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: chip);
  }
}
