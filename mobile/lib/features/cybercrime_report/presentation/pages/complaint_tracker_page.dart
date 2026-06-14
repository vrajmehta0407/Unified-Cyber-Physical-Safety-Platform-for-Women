import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class ComplaintTrackerPage extends StatefulWidget {
  const ComplaintTrackerPage({super.key});

  @override
  State<ComplaintTrackerPage> createState() => _ComplaintTrackerPageState();
}

class _ComplaintTrackerPageState extends State<ComplaintTrackerPage>
    with SingleTickerProviderStateMixin {
  final List<_ComplaintItem> _complaints = _mockComplaints;
  bool _loading = false;
  int? _expandedIndex;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadComplaints();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);
  }

  Future<void> _refresh() => _loadComplaints();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Complaints',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/report-hub'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Complaint',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: _complaints.isEmpty ? _buildEmpty() : _buildList(),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.folder_open, size: 48, color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Text(
              'No Complaints Yet',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your filed complaints will appear here. File your first complaint to get started.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/report-hub'),
              icon: const Icon(Icons.add),
              label: const Text('File a Complaint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        itemBuilder: (context, i) {
          final c = _complaints[i];
          final expanded = _expandedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _expandedIndex = expanded ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: expanded ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                  width: expanded ? 1.5 : 1,
                ),
                boxShadow: expanded
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 12)]
                    : [],
              ),
              child: Column(
                children: [
                  _buildCardHeader(c, expanded),
                  if (expanded) _buildExpandedSection(c),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardHeader(_ComplaintItem c, bool expanded) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  c.id,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _StatusChip(status: c.status),
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.color.withOpacity(0.3)),
                ),
                child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.category,
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Filed: ${c.filedDate}',
                      style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSection(_ComplaintItem c) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stepper timeline
          Text(
            'COMPLAINT PROGRESS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildTimeline(c),
          const SizedBox(height: 16),
          // SLA progress
          if (c.officer != null) ...[
            Row(
              children: [
                const Icon(Icons.badge, color: AppColors.textHint, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Officer: ${c.officer}  ·  Badge ${c.officerBadge}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // SLA bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SLA Progress', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
              Text('${c.slaPercent}%', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: c.slaPercent / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                c.slaPercent >= 80 ? AppColors.danger : c.slaPercent >= 50 ? AppColors.warning : AppColors.success,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_active, size: 16),
                  label: const Text('Push for Update'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(_ComplaintItem c) {
    return Column(
      children: List.generate(c.steps.length, (i) {
        final step = c.steps[i];
        final isLast = i == c.steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.done ? AppColors.success : AppColors.surface,
                        border: Border.all(
                          color: step.done ? AppColors.success : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: step.done
                          ? const Icon(Icons.check, color: Colors.white, size: 10)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.done ? AppColors.success.withOpacity(0.4) : AppColors.border,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: GoogleFonts.spaceGrotesk(
                          color: step.done ? AppColors.textPrimary : AppColors.textHint,
                          fontSize: 13,
                          fontWeight: step.done ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          step.timestamp!,
                          style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 11),
                        ),
                      if (step.note != null)
                        Text(
                          step.note!,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'submitted' => (const Color(0xFF4DA6FF), 'Submitted'),
      'under_review' => (AppColors.warning, 'Under Review'),
      'assigned' => (const Color(0xFFF97316), 'Assigned'),
      'investigation' => (AppColors.primary, 'Investigation'),
      'closed' => (AppColors.success, 'Closed'),
      _ => (AppColors.textHint, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Models ───

class _Step {
  final String label;
  final bool done;
  final String? timestamp;
  final String? note;
  const _Step({required this.label, required this.done, this.timestamp, this.note});
}

class _ComplaintItem {
  final String id;
  final String category;
  final String emoji;
  final Color color;
  final String filedDate;
  final String status;
  final String? officer;
  final String? officerBadge;
  final int slaPercent;
  final List<_Step> steps;

  const _ComplaintItem({
    required this.id,
    required this.category,
    required this.emoji,
    required this.color,
    required this.filedDate,
    required this.status,
    required this.slaPercent,
    required this.steps,
    this.officer,
    this.officerBadge,
  });
}

final _mockComplaints = [
  _ComplaintItem(
    id: 'CYB-AHM-2026-0441',
    category: 'Deepfake Abuse',
    emoji: '🤖',
    color: const Color(0xFFFF3B6B),
    filedDate: '14 Jun 2026, 11:18 AM',
    status: 'under_review',
    officer: 'SI Patel R.',
    officerBadge: '#AHM-4421',
    slaPercent: 35,
    steps: const [
      _Step(label: 'Complaint Submitted', done: true, timestamp: '14 Jun 2026, 11:18 AM', note: 'Filed via CyberShield app'),
      _Step(label: 'Under Review by Cyber Cell', done: true, timestamp: '14 Jun 2026, 12:00 PM'),
      _Step(label: 'Officer Assigned', done: false, note: 'Awaiting assignment'),
      _Step(label: 'Investigation Initiated', done: false),
      _Step(label: 'Case Closed', done: false),
    ],
  ),
  _ComplaintItem(
    id: 'CYB-AHM-2026-0389',
    category: 'Online Financial Fraud',
    emoji: '💸',
    color: AppColors.warning,
    filedDate: '29 May 2026, 03:15 PM',
    status: 'investigation',
    officer: 'SI Mehta K.',
    officerBadge: '#AHM-3812',
    slaPercent: 72,
    steps: const [
      _Step(label: 'Complaint Submitted', done: true, timestamp: '29 May 2026, 03:15 PM'),
      _Step(label: 'Under Review by Cyber Cell', done: true, timestamp: '29 May 2026, 04:00 PM'),
      _Step(label: 'Officer Assigned', done: true, timestamp: '30 May 2026, 09:30 AM', note: 'SI Mehta K. assigned'),
      _Step(label: 'Investigation Initiated', done: true, timestamp: '31 May 2026, 11:00 AM', note: 'Bank transaction logs requested'),
      _Step(label: 'Case Closed', done: false),
    ],
  ),
  _ComplaintItem(
    id: 'CYB-AHM-2026-0301',
    category: 'Cyberstalking',
    emoji: '🔍',
    color: AppColors.primary,
    filedDate: '04 Apr 2026, 10:00 AM',
    status: 'closed',
    officer: 'DSP Sharma A.',
    officerBadge: '#AHM-1234',
    slaPercent: 100,
    steps: const [
      _Step(label: 'Complaint Submitted', done: true, timestamp: '04 Apr 2026, 10:00 AM'),
      _Step(label: 'Under Review by Cyber Cell', done: true, timestamp: '04 Apr 2026, 11:30 AM'),
      _Step(label: 'Officer Assigned', done: true, timestamp: '05 Apr 2026, 09:00 AM'),
      _Step(label: 'Investigation Initiated', done: true, timestamp: '07 Apr 2026, 02:00 PM'),
      _Step(label: 'Case Closed', done: true, timestamp: '22 Apr 2026, 05:00 PM', note: 'Case resolved. Warning issued to accused.'),
    ],
  ),
];
