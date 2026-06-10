import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/file_hash_util.dart';

const _fileTypes = [
  _FileType(Icons.image_outlined,      'Image',    'JPG, PNG, BMP'),
  _FileType(Icons.videocam_outlined,   'Video',    'MP4, MOV, AVI'),
  _FileType(Icons.audiotrack_outlined, 'Audio',    'MP3, WAV, M4A'),
  _FileType(Icons.description_outlined,'Document', 'PDF, DOC, TXT'),
  _FileType(Icons.chat_outlined,       'Chat Log', 'Screenshot, Export'),
  _FileType(Icons.link_outlined,       'Link/URL', 'Web URL'),
];

class _FileType {
  final IconData icon;
  final String label;
  final String hint;
  const _FileType(this.icon, this.label, this.hint);
}

const _incidentOptions = [
  'INC-2024-1001',
  'INC-2024-1002',
  'INC-2024-1003',
  'New Incident',
];

class UploadEvidencePage extends StatefulWidget {
  const UploadEvidencePage({super.key});

  @override
  State<UploadEvidencePage> createState() => _UploadEvidencePageState();
}

class _UploadEvidencePageState extends State<UploadEvidencePage> {
  bool _loading = false;
  List<File> _selectedFiles = [];
  final Map<String, String> _hashes = {};
  String _selectedIncident = 'INC-2024-1001';
  int? _selectedTypeIdx;
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
        if (mounted) setState(() => _hashes[file.path] = 'Unable to calculate');
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_selectedFiles.length} file(s) uploaded & encrypted'),
          backgroundColor: AppColors.success,
        ));
        setState(() {
          _selectedFiles = [];
          _hashes.clear();
          _selectedTypeIdx = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildIncidentSelector(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Upload Files'),
                  const SizedBox(height: 12),
                  _buildFileTypeGrid(),
                  const SizedBox(height: 20),
                  if (_selectedFiles.isNotEmpty) ...[
                    _buildSectionLabel('Selected Files (${_selectedFiles.length})'),
                    const SizedBox(height: 12),
                    _buildFilesList(),
                    const SizedBox(height: 20),
                  ],
                  _buildEncryptionNotice(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Upload Evidence',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _buildIncidentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Select Incident'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedIncident,
              isExpanded: true,
              dropdownColor: AppColors.card,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _selectedIncident = v!),
              items: _incidentOptions.map((o) => DropdownMenuItem(
                value: o,
                child: Text(o),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: _fileTypes.length,
      itemBuilder: (_, i) {
        final ft = _fileTypes[i];
        final isSelected = _selectedTypeIdx == i;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedTypeIdx = i);
            _pickFiles();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(ft.icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
                ),
                const SizedBox(height: 6),
                Text(ft.label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    )),
                Text(ft.hint,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppColors.textHint,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilesList() {
    return Column(
      children: _selectedFiles.map((file) {
        final name = file.path.split(Platform.pathSeparator).last;
        final hash = _hashes[file.path];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      hash == null ? 'Computing SHA-256...' : 'SHA-256: ${hash.substring(0, 20)}...',
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (hash != null)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEncryptionNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'All files are encrypted and securely stored with AES-256 encryption',
              style: GoogleFonts.outfit(color: AppColors.success, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    final enabled = _selectedFiles.isNotEmpty && !_loading;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GestureDetector(
        onTap: enabled ? _uploadAll : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(colors: AppColors.primaryGradient)
                : const LinearGradient(colors: [Color(0xFF3A2860), Color(0xFF2A1A50)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedFiles.isEmpty ? 'Select Files to Upload' : 'Upload',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
