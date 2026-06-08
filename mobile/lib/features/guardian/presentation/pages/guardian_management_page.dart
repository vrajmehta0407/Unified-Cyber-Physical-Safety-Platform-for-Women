import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class GuardianManagementPage extends StatefulWidget {
  const GuardianManagementPage({super.key});

  @override
  State<GuardianManagementPage> createState() => _GuardianManagementPageState();
}

class _GuardianManagementPageState extends State<GuardianManagementPage> {
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  bool _offlineMode = false;
  final _api = ServiceLocator.instance.guardians;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _api.listGuardians();
      setState(() {
        _list = items;
        _offlineMode = false;
      });
    } catch (_) {
      setState(() {
        _offlineMode = true;
        _list = [
          {
            'id': 'local-1',
            'name': 'Priya Sharma',
            'phone': '+91 98765 43210',
            'relation': 'Sister'
          },
          {
            'id': 'local-2',
            'name': 'Ahmedabad Police Control',
            'phone': '112',
            'relation': 'Emergency'
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addGuardian() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Guardian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(labelText: 'Relation')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add')),
        ],
      ),
    );
    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final relation = relationCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    try {
      if (_offlineMode) throw Exception('Offline demo mode');
      await _api.addGuardian(
        name: name,
        phone: phone,
        relation: relation.isEmpty ? null : relation,
      );
      _load();
    } catch (_) {
      setState(() {
        _offlineMode = true;
        _list = [
          ..._list,
          {
            'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
            'name': name,
            'phone': phone,
            'relation': relation.isEmpty ? 'Contact' : relation,
          },
        ];
      });
    }
  }

  Future<void> _removeGuardian(int index) async {
    final guardian = _list[index];
    try {
      if (_offlineMode) throw Exception('Offline demo mode');
      await _api.removeGuardian(guardian['id'].toString());
      _load();
    } catch (_) {
      setState(() => _list.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Guardians')),
      floatingActionButton: FloatingActionButton(
          onPressed: _addGuardian, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('No guardians added yet'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: _list.length + (_offlineMode ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_offlineMode && i == 0) return const _GuardianNotice();
                    final index = _offlineMode ? i - 1 : i;
                    final g = _list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(g['name']?.toString() ?? ''),
                        subtitle: Text(
                            '${g['phone']} - ${g['relation'] ?? 'Contact'}'),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: AppColors.danger),
                          onPressed: () => _removeGuardian(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _GuardianNotice extends StatelessWidget {
  const _GuardianNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_active_outlined,
              color: AppColors.warning, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo guardian list active. SOS will auto-notify saved contacts when backend sync is available.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
