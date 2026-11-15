import 'package:flutter/material.dart';
import '../core/ddragon_service.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';

class ChampionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> champion;
  final DDragonService service;
  const ChampionDetailScreen({super.key, required this.champion, required this.service});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(champion['name'].toString())),
    body: FutureBuilder<Map<String, dynamic>>(
      future: service.championDetail(champion['id'].toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingPanel();
        if (snapshot.hasError) return ErrorPanel(snapshot.error.toString());
        final c = snapshot.data!;
        final spells = (c['spells'] as List? ?? []);
        return ListView(padding: const EdgeInsets.all(18), children: [
          ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network('https://ddragon.leagueoflegends.com/cdn/${service.version}/img/splash/${c['id']}_0.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.network(service.championIcon(c['id'].toString())))),
          const SizedBox(height: 15),
          Text(c['name'].toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          Text(c['title'].toString(), style: const TextStyle(color: RiftTheme.gold)),
          const SizedBox(height: 13),
          Text(c['blurb'].toString(), style: const TextStyle(color: Colors.white70, height: 1.5)),
          const SizedBox(height: 20),
          const Text('Base attributes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: (c['tags'] as List? ?? []).map((t) => Chip(label: Text(t.toString()))).toList()),
          ...((c['stats'] as Map<String, dynamic>).entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(_pretty(e.key), style: const TextStyle(color: Colors.white70))), Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w800))])))),
          const SizedBox(height: 20),
          const Text('Abilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _Ability(name: 'Passive · ${c['passive']['name']}', description: c['passive']['description'], image: 'https://ddragon.leagueoflegends.com/cdn/${service.version}/img/passive/${c['passive']['image']['full']}'),
          ...spells.map((s) => _Ability(name: '${s['name']}', description: s['description'], image: 'https://ddragon.leagueoflegends.com/cdn/${service.version}/img/spell/${s['image']['full']}')),
        ]);
      },
    ),
  );

  static String _pretty(String value) => value.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}').trim();
}

class _Ability extends StatelessWidget {
  final String name; final String description; final String image;
  const _Ability({required this.name, required this.description, required this.image});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.network(image, width: 44, height: 44, errorBuilder: (_, __, ___) => const Icon(Icons.bolt, size: 40))),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(description.replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4))])),
  ]));
}
