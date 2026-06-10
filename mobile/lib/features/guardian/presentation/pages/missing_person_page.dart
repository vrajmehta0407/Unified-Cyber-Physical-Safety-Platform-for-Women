import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

const _mockMatches = [
  _Match('Match 1', 85),
  _Match('Match 2', 78),
  _Match('Match 3', 66),
];

class _Match {
  final String label;
  final int similarity;
  const _Match(this.label, this.similarity);
}

class MissingPersonPage extends StatefulWidget {
  const MissingPersonPage({super.key});

  @override
  State<MissingPersonPage> createState() => _MissingPersonPageState();
}

class _MissingPersonPageState extends State<MissingPersonPage> {
  File? _photo;
  bool _searching = false;
  bool _hasResults = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _photo = File(picked.path);
      _hasResults = false;
    });
  }

  Future<void> _search() async {
    if (_photo == null) return;
    setState(() => _searching = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _searching = false; _hasResults = true; });
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
                children: [
                  const SizedBox(height: 8),
                  _buildUploadSection(),
                  if (_hasResults) ...[
                    const SizedBox(height: 24),
                    _buildMatches(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Missing Person Assist',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('AI facial recognition search',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('Upload Photo',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _photo != null ? AppColors.primary : AppColors.border,
                  style: BorderStyle.solid,
                  width: _photo != null ? 1.5 : 1,
                ),
              ),
              child: _photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(_photo!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add_outlined, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text('Tap to Upload Photo',
                            style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('JPG, PNG, BMP',
                            style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: (_photo != null && !_searching) ? _search : null,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: _photo != null
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : const LinearGradient(colors: [Color(0xFF3A2860), Color(0xFF2A1A50)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _photo != null
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))]
                    : [],
              ),
              child: Center(
                child: _searching
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text('Searching...', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('Search for Matches',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Potential Matches',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ..._mockMatches.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MatchCard(match: m),
            )),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text('View All Matches',
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final _Match match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final color = match.similarity >= 80 ? AppColors.danger : match.similarity >= 70 ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(Icons.person_outlined, color: AppColors.textSecondary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.label,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${match.similarity}% Similarity',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text('${match.similarity}%',
                style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
