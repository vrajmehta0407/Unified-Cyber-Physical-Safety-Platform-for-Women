import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../ai_protection/presentation/widgets/risk_score_widget.dart';

class SocialMediaScannerPage extends StatefulWidget {
  const SocialMediaScannerPage({super.key});

  @override
  State<SocialMediaScannerPage> createState() => _SocialMediaScannerPageState();
}

class _SocialMediaScannerPageState extends State<SocialMediaScannerPage> {
  final _usernameController = TextEditingController();
  String _platform = 'instagram';
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _scan() async {
    if (_usernameController.text.trim().isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await ServiceLocator.instance.ai.analyzeFakeProfile(
        username: _usernameController.text.trim(),
        platform: _platform,
      );
      setState(() => _result = result);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (_result?['risk_score'] as num?)?.toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('Social Media Risk Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['instagram', 'facebook', 'twitter'].map((p) => ChoiceChip(
                label: Text(p),
                selected: _platform == p,
                onSelected: (_) => setState(() => _platform = p),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username or profile link')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _scan,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Scan Profile'),
            ),
            if (score != null) ...[
              const SizedBox(height: 32),
              RiskScoreWidget(score: score, label: score >= 60 ? 'High Risk' : 'Moderate Risk'),
              const SizedBox(height: 12),
              Text(_result?['message']?.toString() ?? '', textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
