import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../widgets/risk_score_widget.dart';

class PhishingCheckerPage extends StatefulWidget {
  const PhishingCheckerPage({super.key});

  @override
  State<PhishingCheckerPage> createState() => _PhishingCheckerPageState();
}

class _PhishingCheckerPageState extends State<PhishingCheckerPage> {
  final _urlController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  final _ai = ServiceLocator.instance.ai;

  Future<void> _check() async {
    if (_urlController.text.trim().isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await _ai.checkPhishing(_urlController.text.trim());
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
      appBar: AppBar(title: const Text('Phishing Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'Enter URL or paste SMS')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _check,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Analyze'),
            ),
            if (score != null) ...[
              const SizedBox(height: 32),
              RiskScoreWidget(
                score: score,
                label: score >= 60 ? 'High Risk' : score >= 30 ? 'Moderate Risk' : 'Low Risk',
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
