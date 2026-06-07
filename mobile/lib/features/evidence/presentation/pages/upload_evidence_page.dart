import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class UploadEvidencePage extends StatefulWidget {
  const UploadEvidencePage({super.key});

  @override
  State<UploadEvidencePage> createState() => _UploadEvidencePageState();
}

class _UploadEvidencePageState extends State<UploadEvidencePage> {
  bool _loading = false;
  List<File> _selectedFiles = [];
  final _evidence = ServiceLocator.instance.evidence;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.whereType<String>().map((p) => File(p)).toList();
      });
    }
  }

  Future<void> _uploadAll() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _loading = true);
    try {
      for (final file in _selectedFiles) {
        await _evidence.uploadFile(file: file);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedFiles.length} file(s) uploaded & encrypted')),
        );
        setState(() => _selectedFiles = []);
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
      appBar: AppBar(title: const Text('Upload Evidence')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔒 Files are encrypted with AES-256', style: TextStyle(color: AppColors.success, fontSize: 13)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _UploadButton(icon: Icons.image, label: 'Image', onTap: _pickFiles),
                _UploadButton(icon: Icons.videocam, label: 'Video', onTap: _pickFiles),
                _UploadButton(icon: Icons.audiotrack, label: 'Audio', onTap: _pickFiles),
                _UploadButton(icon: Icons.description, label: 'Document', onTap: _pickFiles),
              ],
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Selected (${_selectedFiles.length}):', style: const TextStyle(fontWeight: FontWeight.w600)),
              ..._selectedFiles.map((f) => Text('• ${f.path.split(Platform.pathSeparator).last}', style: const TextStyle(fontSize: 13))),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading || _selectedFiles.isEmpty ? null : _uploadAll,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_selectedFiles.isEmpty ? 'Select Files First' : 'Upload Selected Files'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _UploadButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          height: 90,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
