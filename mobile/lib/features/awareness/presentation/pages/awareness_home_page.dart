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
  String? _fallbackNotice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _fallbackNotice = null;
    });
    try {
      final articles =
          await ServiceLocator.instance.awareness.getArticles(language: _lang);
      setState(() {
        _articles = articles.isEmpty ? _fallbackArticles(_lang) : articles;
        if (articles.isEmpty) {
          _fallbackNotice = 'Showing built-in awareness guides';
        }
      });
    } catch (e) {
      setState(() {
        _articles = _fallbackArticles(_lang);
        _fallbackNotice = 'Showing built-in awareness guides';
      });
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
            onSelected: (v) {
              setState(() => _lang = v);
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'hi', child: Text('Hindi')),
              const PopupMenuItem(value: 'gu', child: Text('Gujarati')),
            ],
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_lang.toUpperCase())),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length + (_fallbackNotice == null ? 0 : 1),
              itemBuilder: (_, i) {
                if (_fallbackNotice != null && i == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.info.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.info, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(_fallbackNotice!,
                                style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  );
                }
                final articleIndex = _fallbackNotice == null ? i : i - 1;
                final a = _articles[articleIndex];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading:
                        const Icon(Icons.lightbulb, color: AppColors.warning),
                    title: Text(a['title']?.toString() ?? ''),
                    subtitle: Text(a['category']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12)),
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

  List<Map<String, dynamic>> _fallbackArticles(String language) {
    final catalog = <String, List<Map<String, dynamic>>>{
      'en': [
        {
          'title': 'Before you share a link',
          'category': 'Phishing',
          'body':
              'Check the sender, domain spelling, urgency language, and payment requests. Use the Phishing Checker before opening unknown links.',
        },
        {
          'title': 'Preserve digital evidence',
          'category': 'Evidence',
          'body':
              'Do not edit screenshots or videos. Upload original files to the Evidence Vault so the SHA-256 hash can prove integrity.',
        },
        {
          'title': 'Emergency safety routine',
          'category': 'SOS',
          'body':
              'Add guardians, test Offline SOS, enable voice SOS, and keep location permissions enabled before travelling alone.',
        },
      ],
      'hi': [
        {
          'title': 'Link kholne se pehle',
          'category': 'Phishing',
          'body':
              'Sender, domain spelling, jaldi karne wali language aur payment request check karein. Unknown link ke liye Phishing Checker use karein.',
        },
        {
          'title': 'Digital evidence sambhalein',
          'category': 'Evidence',
          'body':
              'Screenshot ya video edit na karein. Original file Evidence Vault me upload karein taaki SHA-256 hash integrity prove kar sake.',
        },
        {
          'title': 'Emergency safety routine',
          'category': 'SOS',
          'body':
              'Guardians add karein, Offline SOS test karein, voice SOS enable karein, aur travel se pehle location permission on rakhein.',
        },
      ],
      'gu': [
        {
          'title': 'Link kholta pehla',
          'category': 'Phishing',
          'body':
              'Sender, domain spelling, urgent language ane payment request check karo. Unknown link mate Phishing Checker vapro.',
        },
        {
          'title': 'Digital evidence sachvo',
          'category': 'Evidence',
          'body':
              'Screenshot ke video edit na karo. Original file Evidence Vault ma upload karo jethi SHA-256 hash integrity batavi shake.',
        },
        {
          'title': 'Emergency safety routine',
          'category': 'SOS',
          'body':
              'Guardians add karo, Offline SOS test karo, voice SOS enable karo, ane travel pehla location permission on rakho.',
        },
      ],
    };
    return catalog[language] ?? catalog['en']!;
  }
}
