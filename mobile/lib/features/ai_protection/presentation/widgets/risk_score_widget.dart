import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RiskScoreWidget extends StatelessWidget {
  final double score;
  final String label;

  const RiskScoreWidget({super.key, required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = score >= 60 ? AppColors.danger : score >= 30 ? AppColors.warning : AppColors.success;
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: score / 100, strokeWidth: 8, color: color, backgroundColor: AppColors.border),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${score.toInt()}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 11, color: color)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
