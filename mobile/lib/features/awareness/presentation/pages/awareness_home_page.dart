import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

class AwarenessHomePage extends StatefulWidget {
  const AwarenessHomePage({super.key});

  @override
  State<AwarenessHomePage> createState() => _AwarenessHomePageState();
}

class _AwarenessHomePageState extends State<AwarenessHomePage> {
  String _lang = 'en';
  List<Map<String, dynamic>> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final articles = await ServiceLocator.instance.awareness.getArticles(language: _lang);
      setState(() => _articles = articles);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _lang = v); _load(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'hi', child: Text('Hindi')),
              const PopupMenuItem(value: 'gu', child: Text('Gujarati')),
            ],
            child: Padding(padding: const EdgeInsets.all(16), child: Text(_lang.toUpperCase())),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (_, i) {
                final a = _articles[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.lightbulb, color: AppColors.warning),
                    title: Text(a['title']?.toString() ?? ''),
                    subtitle: Text(a['category']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(a['body']?.toString() ?? ''),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
