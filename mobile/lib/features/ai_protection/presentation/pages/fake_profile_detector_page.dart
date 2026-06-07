import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../widgets/risk_score_widget.dart';

class FakeProfileDetectorPage extends StatefulWidget {
  const FakeProfileDetectorPage({super.key});

  @override
  State<FakeProfileDetectorPage> createState() => _FakeProfileDetectorPageState();
}

class _FakeProfileDetectorPageState extends State<FakeProfileDetectorPage> {
  final _usernameController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  final _ai = ServiceLocator.instance.ai;

  Future<void> _analyze() async {
    if (_usernameController.text.trim().isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await _ai.analyzeFakeProfile(username: _usernameController.text.trim());
      setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (_result?['risk_score'] as num?)?.toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('Fake Profile Detector')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Instagram / social username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _analyze,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Analyze Profile'),
            ),
            if (score != null) ...[
              const SizedBox(height: 32),
              RiskScoreWidget(
                score: score,
                label: score >= 60 ? 'High Risk' : score >= 35 ? 'Moderate Risk' : 'Low Risk',
              ),
              const SizedBox(height: 12),
              Text(_result?['message']?.toString() ?? '', textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
