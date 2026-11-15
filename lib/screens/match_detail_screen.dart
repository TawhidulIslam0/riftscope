
import 'package:flutter/material.dart';
import '../core/ddragon_service.dart';
import '../core/formatters.dart';
import '../core/regions.dart';
import '../core/theme.dart';

class MatchDetailScreen extends StatelessWidget {
  final Map<String, dynamic> match;
  final RegionInfo region;
  const MatchDetailScreen({super.key, required this.match, required this.region});

  @override
  Widget build(BuildContext context) {
    final info = match['info'] as Map<String, dynamic>;
    final participants = (info['participants'] as List? ?? []).cast<Map<String, dynamic>>();
    final blue = participants.where((p) => p['teamId'] == 100).toList();
    final red = participants.where((p) => p['teamId'] == 200).toList();
    final blueWin = blue.isNotEmpty && blue.first['win'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Match details')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Text('${info['gameMode'] ?? 'Game'} · ${duration((info['gameDuration'] ?? 0) as int)}', style: const TextStyle(color: RiftTheme.muted)),
          const SizedBox(height: 7),
          Text('Patch ${info['gameVersion'] ?? '—'}', style: const TextStyle(color: RiftTheme.gold, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(blueWin ? 'BLUE TEAM VICTORY' : 'RED TEAM VICTORY', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: blueWin ? RiftTheme.accent : const Color(0xFFE45D6A))),
        ])),
        const SizedBox(height: 18),
        _Team(title: 'Blue team', players: blue, won: blueWin),
        const SizedBox(height: 12),
        _Team(title: 'Red team', players: red, won: !blueWin),
      ]),
    );
  }
}

class _Team extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> players;
  final bool won;
  const _Team({required this.title, required this.players, required this.won});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const Spacer(),
        Text(won ? 'WIN' : 'LOSS', style: TextStyle(color: won ? RiftTheme.accent : const Color(0xFFE45D6A), fontSize: 11, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 10),
      ...players.map((p) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(children: [
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(DDragonService().championIcon(p['championName'].toString()), width: 38, height: 38, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 34))),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                p['riotIdGameName']?.toString().isNotEmpty == true
                    ? '${p['riotIdGameName']}#${p['riotIdTagline'] ?? ''}'
                    : (p['summonerName'] ?? p['championName']).toString(),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(p['championName'].toString(), style: const TextStyle(color: RiftTheme.muted, fontSize: 10)),
            ])),
            Text('${p['kills']}/${p['deaths']}/${p['assists']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(width: 8),
            Text('${p['totalMinionsKilled'] ?? 0} CS', style: const TextStyle(color: RiftTheme.muted, fontSize: 10)),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            const SizedBox(width: 47),
            ...List.generate(7, (i) {
              final itemId = p['item$i'] ?? 0;
              if (itemId == 0) return Container(
                width: 27, height: 27, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: RiftTheme.surface2, borderRadius: BorderRadius.circular(5)),
              );
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(DDragonService().itemIcon('$itemId'), width: 27, height: 27,
                    errorBuilder: (_, __, ___) => Container(width: 27, height: 27, color: RiftTheme.surface2)),
                ),
              );
            }),
          ]),
        ]),
      )),
    ]),
  );
}
