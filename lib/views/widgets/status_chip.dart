import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({super.key, required this.status});

  Color _getStatusColor() {
    final s = status.toLowerCase();
    if (s.contains('progress') || s.contains('aktif')) {
      return AppTheme.primaryAccent;
    } else if (s.contains('complet') || s.contains('selesai') || s.contains('paid') || s.contains('lunas')) {
      return AppTheme.successAccent;
    } else if (s.contains('invoice') || s.contains('pending') || s.contains('tertunda')) {
      return AppTheme.warningAccent;
    } else if (s.contains('overdue') || s.contains('telat')) {
      return AppTheme.errorAccent;
    } else {
      return AppTheme.textSecondary; // On Hold / Default
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
