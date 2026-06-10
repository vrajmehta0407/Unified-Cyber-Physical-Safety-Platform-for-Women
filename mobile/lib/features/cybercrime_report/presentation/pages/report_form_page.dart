import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

const _categories = [
  _CrimeCat(Icons.location_on_outlined,    'Cyber Stalking',       'Persistent online harassment'),
  _CrimeCat(Icons.person_off_outlined,     'Online Harassment',    'Abusive messages or threats'),
  _CrimeCat(Icons.face_outlined,           'Fake Profile',         'Impersonation on social media'),
  _CrimeCat(Icons.account_balance_outlined,'Financial Fraud',      'Online financial deception'),
  _CrimeCat(Icons.badge_outlined,          'Identity Theft',       'Unauthorized use of identity'),
  _CrimeCat(Icons.lock_outline,            'Blackmail',            'Threats using personal info'),
  _CrimeCat(Icons.face_retouching_off,     'Deepfake Abuse',       'Manipulated images or videos'),
  _CrimeCat(Icons.phishing_outlined,       'Phishing Attack',      'Fraudulent links or messages'),
];

class _CrimeCat {
  final IconData icon;
  final String label;
  final String desc;
  const _CrimeCat(this.icon, this.label, this.desc);
}

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  int _step = 1;
  String? _selectedCategory;
  bool _loading = false;
  final _descCtrl = TextEditingController();
  final _reports = ServiceLocator.instance.reports;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCategory == null || _descCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final result = await _reports.submitReport(
        category: _selectedCategory!,
        description: _descCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Report submitted! ID: ${result['id']}'),
          backgroundColor: AppColors.success,
        ));
        context.pop();
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
          _buildStepIndicator(),
          Expanded(
            child: _step == 1 ? _buildStep1() : _buildStep2(),
          ),
          _buildBottomButton(context),
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
                onTap: () {
                  if (_step == 2) {
                    setState(() => _step = 1);
                  } else {
                    context.pop();
                  }
                },
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
                'Report Cyber Crime',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _StepDot(number: 1, label: 'Select Category', isActive: _step == 1, isDone: _step > 1),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _step > 1
                      ? const [AppColors.primary, AppColors.primary]
                      : [AppColors.primary, AppColors.border],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _StepDot(number: 2, label: 'Describe Incident', isActive: _step == 2, isDone: false),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final cat = _categories[i];
        final isSelected = _selectedCategory == cat.label;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    cat.icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.label,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat.desc,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  size: isSelected ? 20 : 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category_outlined, color: AppColors.primary, size: 15),
                const SizedBox(width: 8),
                Text(
                  _selectedCategory ?? '',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Describe the Incident',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: null,
                expands: true,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe what happened, when, and where...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Encryption notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All data is encrypted and securely stored',
                    style: GoogleFonts.outfit(color: AppColors.success, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GestureDetector(
        onTap: _loading
            ? null
            : () {
                if (_step == 1 && _selectedCategory != null) {
                  setState(() => _step = 2);
                } else if (_step == 2) {
                  _submit();
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: (_step == 1 && _selectedCategory == null)
                ? const LinearGradient(colors: [Color(0xFF4A3870), Color(0xFF3A2860)])
                : const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: (_step == 1 && _selectedCategory == null)
                ? []
                : [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    _step == 1 ? 'Next' : 'Submit Report',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;
  const _StepDot({required this.number, required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isActive || isDone) ? AppColors.primary : AppColors.card,
            border: Border.all(
              color: (isActive || isDone) ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    '$number',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
