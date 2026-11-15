import 'package:flutter/material.dart';
import '../core/ddragon_service.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';
import 'champion_detail_screen.dart';

class ChampionsScreen extends StatefulWidget {
  const ChampionsScreen({super.key});
  @override
  State<ChampionsScreen> createState() => _ChampionsScreenState();
}

class _ChampionsScreenState extends State<ChampionsScreen> {
  final service = DDragonService();
  final search = TextEditingController();
  String query = '';
  late Future<Map<String, dynamic>> future;
  @override
  void initState() { super.initState(); future = service.champions(); }
  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Champions', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 7),
      const Text('Official champion data from Riot Data Dragon.', style: TextStyle(color: RiftTheme.muted)),
      const SizedBox(height: 15),
      TextField(controller: search, onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search champions')),
    ])),
    Expanded(child: FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingPanel();
        if (snapshot.hasError) return ErrorPanel(snapshot.error.toString(), onRetry: () => setState(() => future = service.champions()));
        final entries = snapshot.data!.values.where((c) => c['name'].toString().toLowerCase().contains(query.toLowerCase()) || c['title'].toString().toLowerCase().contains(query.toLowerCase())).toList()
          ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        return GridView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 12, childAspectRatio: .78), itemCount: entries.length, itemBuilder: (context, i) {
          final c = entries[i];
          return InkWell(borderRadius: BorderRadius.circular(14), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChampionDetailScreen(champion: c, service: service))), child: Container(decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(14)), clipBehavior: Clip.antiAlias, child: Column(children: [
            Expanded(child: Image.network('https://ddragon.leagueoflegends.com/cdn/${service.version}/img/champion/${c['id']}.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 45))),
            Padding(padding: const EdgeInsets.all(8), child: Column(children: [Text(c['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), Text(c['title'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RiftTheme.muted, fontSize: 9))])),
          ])));
        });
      },
    )),
  ]);
}
