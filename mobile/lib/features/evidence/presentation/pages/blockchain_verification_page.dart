import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class BlockchainVerificationPage extends StatefulWidget {
  const BlockchainVerificationPage({super.key});

  @override
  State<BlockchainVerificationPage> createState() => _BlockchainVerificationPageState();
}

class _BlockchainVerificationPageState extends State<BlockchainVerificationPage> {
  final _hashController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _loading = false;

  Future<void> _verify() async {
    if (_hashController.text.trim().length < 8) return;
    setState(() { _loading = true; _result = null; });
    try {
      final result = await ServiceLocator.instance.evidence.verifyHash(_hashController.text.trim());
      setState(() => _result = result);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verified = _result?['verified'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hashController,
              decoration: const InputDecoration(labelText: 'SHA-256 Hash or Evidence ID'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify on Blockchain'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(verified ? Icons.verified : Icons.error, color: verified ? AppColors.success : AppColors.danger),
                        const SizedBox(width: 8),
                        Text(verified ? 'Verified on Blockchain' : 'Not Verified', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                      if (verified) ...[
                        const SizedBox(height: 16),
                        _MetaRow('Evidence ID', _result!['evidence_id']?.toString() ?? ''),
                        _MetaRow('SHA-256', '${_result!['hash']?.toString().substring(0, 16)}...'),
                        _MetaRow('Block Number', _result!['block_number']?.toString() ?? ''),
                        _MetaRow('Network', _result!['network']?.toString() ?? ''),
                        _MetaRow('Status', _result!['status']?.toString() ?? ''),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(color: AppColors.textSecondary)), Text(value)],
      ),
    );
  }
}
