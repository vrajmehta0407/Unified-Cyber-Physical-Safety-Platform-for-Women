import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      setState(() => _list = items);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'Relation')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true) {
      await ServiceLocator.instance.guardians.addGuardian(
        name: nameCtrl.text,
        phone: phoneCtrl.text,
        relation: relationCtrl.text.isEmpty ? null : relationCtrl.text,
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Guardians')),
      floatingActionButton: FloatingActionButton(onPressed: _addGuardian, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('No guardians added yet'))
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, i) {
                    final g = _list[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(g['name']?.toString() ?? ''),
                        subtitle: Text('${g['phone']} · ${g['relation'] ?? 'Contact'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.danger),
                          onPressed: () async {
                            await ServiceLocator.instance.guardians.removeGuardian(g['id'].toString());
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
