import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DeepfakeResultWidget extends StatelessWidget {
  final String verdict;
  final double confidence;
  final Map<String, String> factors;

  const DeepfakeResultWidget({
    super.key,
    required this.verdict,
    required this.confidence,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(verdict == 'fake' ? Icons.warning : Icons.check_circle,
                    color: verdict == 'fake' ? AppColors.danger : AppColors.success),
                const SizedBox(width: 8),
                Text('Verdict: ${verdict.toUpperCase()} (${confidence.toInt()}% confidence)',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...factors.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(e.value, style: TextStyle(
                    color: e.value == 'High' ? AppColors.danger : e.value == 'Medium' ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
