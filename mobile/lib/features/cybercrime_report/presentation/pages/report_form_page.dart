import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

const _categories = [
  'Cyber Stalking', 'Online Harassment', 'Fake Profile',
  'Financial Fraud', 'Identity Theft', 'Blackmail',
  'Deepfake Abuse', 'Phishing Attack',
];

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  String? _selectedCategory;
  bool _loading = false;
  final _descriptionController = TextEditingController();
  final _reports = ServiceLocator.instance.reports;

  Future<void> _submit() async {
    if (_selectedCategory == null || _descriptionController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final result = await _reports.submitReport(
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted! ID: ${result['id']}')),
        );
        Navigator.pop(context);
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report Cyber Crime')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._categories.map((cat) => Card(
            child: RadioListTile(
              title: Text(cat),
              value: cat,
              groupValue: _selectedCategory,
              activeColor: AppColors.primary,
              onChanged: _loading ? null : (v) => setState(() => _selectedCategory = v as String?),
            ),
          )),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            enabled: !_loading,
            decoration: const InputDecoration(labelText: 'Describe the incident'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading || _selectedCategory == null ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
