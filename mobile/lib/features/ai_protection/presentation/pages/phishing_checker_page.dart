import 'package:flutter/material.dart';
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
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final result = await _ai.checkPhishing(_urlController.text.trim());
      setState(() => _result = result);
    } catch (e) {
      setState(
          () => _result = _localPhishingAnalysis(_urlController.text.trim()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _localPhishingAnalysis(String input) {
    var score = 12;
    final lower = input.toLowerCase();
    final redFlags = [
      'verify',
      'urgent',
      'password',
      'otp',
      'bank',
      'prize',
      'free',
      'bit.ly',
      'tinyurl',
      'login'
    ];
    for (final flag in redFlags) {
      if (lower.contains(flag)) score += 10;
    }
    if (!lower.startsWith('https://') && lower.contains('.')) score += 12;
    if (RegExp(r'\d{1,3}(\.\d{1,3}){3}').hasMatch(lower)) score += 18;
    score = score.clamp(0, 96);
    return {
      'risk_score': score,
      'message':
          'Local fallback analysis used: ${score >= 60 ? 'multiple phishing indicators found' : score >= 30 ? 'some caution indicators found' : 'no major red flags found'}.',
    };
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
            TextField(
                controller: _urlController,
                decoration:
                    const InputDecoration(labelText: 'Enter URL or paste SMS')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _check,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze'),
            ),
            if (score != null) ...[
              const SizedBox(height: 32),
              RiskScoreWidget(
                score: score,
                label: score >= 60
                    ? 'High Risk'
                    : score >= 30
                        ? 'Moderate Risk'
                        : 'Low Risk',
              ),
              const SizedBox(height: 12),
              Text(_result?['message']?.toString() ?? '',
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
