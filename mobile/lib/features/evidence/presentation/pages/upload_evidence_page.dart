import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/file_hash_util.dart';

class UploadEvidencePage extends StatefulWidget {
  const UploadEvidencePage({super.key});

  @override
  State<UploadEvidencePage> createState() => _UploadEvidencePageState();
}

class _UploadEvidencePageState extends State<UploadEvidencePage> {
  bool _loading = false;
  List<File> _selectedFiles = [];
  final Map<String, String> _hashes = {};
  final _evidence = ServiceLocator.instance.evidence;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final files = result.paths.whereType<String>().map((p) => File(p)).toList();
    setState(() {
      _selectedFiles = files;
      _hashes.clear();
    });
    await _calculateHashes(files);
  }

  Future<void> _calculateHashes(List<File> files) async {
    for (final file in files) {
      try {
        final hash = FileHashUtil.sha256(await file.readAsBytes());
        if (mounted) setState(() => _hashes[file.path] = hash);
      } catch (_) {
        if (mounted) {
          setState(() => _hashes[file.path] = 'Unable to calculate hash');
        }
      }
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
          SnackBar(
              content: Text(
                  '${_selectedFiles.length} file(s) uploaded, encrypted, and hashed')),
        );
        setState(() {
          _selectedFiles = [];
          _hashes.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Vault')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.success, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AES-256 secure upload with local SHA-256 evidence fingerprints.',
                      style:
                          TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _UploadButton(
                    icon: Icons.image, label: 'Image', onTap: _pickFiles),
                _UploadButton(
                    icon: Icons.videocam, label: 'Video', onTap: _pickFiles),
                _UploadButton(
                    icon: Icons.audiotrack, label: 'Audio', onTap: _pickFiles),
                _UploadButton(
                    icon: Icons.description,
                    label: 'Document',
                    onTap: _pickFiles),
              ],
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Selected evidence (${_selectedFiles.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: _selectedFiles.map((file) {
                    final name = file.path.split(Platform.pathSeparator).last;
                    final hash = _hashes[file.path];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined,
                            color: AppColors.primary),
                        title: Text(name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          hash == null
                              ? 'Calculating SHA-256...'
                              : 'SHA-256: ${hash.length > 24 ? '${hash.substring(0, 24)}...' : hash}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ] else
              const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _loading || _selectedFiles.isEmpty ? null : _uploadAll,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_selectedFiles.isEmpty
                        ? 'Select Files First'
                        : 'Upload to Vault'),
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
  const _UploadButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 100,
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
