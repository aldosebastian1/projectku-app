import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class CustomProgressBar extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final bool isOverdue;

  const CustomProgressBar({
    super.key,
    required this.percentage,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    Color trackColor;
    if (isOverdue) {
      trackColor = AppTheme.errorAccent;
    } else if (percentage >= 1.0) {
      trackColor = AppTheme.successAccent;
    } else if (percentage > 0.8) {
      // Near completion or less than 3 days
      trackColor = AppTheme.warningAccent;
    } else {
      trackColor = AppTheme.primaryAccent;
    }

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.border, // Very light grey background
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * percentage.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }
}
