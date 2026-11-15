
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/ddragon_service.dart';
import '../core/regions.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';

class LiveGameScreen extends StatefulWidget {
  final RegionInfo region;
  final String puuid;
  final String playerName;
  const LiveGameScreen({super.key, required this.region, required this.puuid, required this.playerName});
  @override
  State<LiveGameScreen> createState() => _LiveGameScreenState();
}

class _LiveGameScreenState extends State<LiveGameScreen> {
  late Future<Map<String, dynamic>> future;
  @override
  void initState() { super.initState(); future = load(); }
  Future<Map<String, dynamic>> load() async {
    await DDragonService().initialize();
    return ApiClient().getMap('/api/live/${widget.region.platform}/${widget.puuid}');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Live game')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const LoadingPanel();
        if (snap.hasError) {
          final message = snap.error.toString();
          final noGame = message.contains('not found') || message.contains('404');
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ErrorPanel(
              noGame ? 'No active game was found for ${widget.playerName}. This is normal when the player is not currently in a supported live game.' : message,
              onRetry: () => setState(() => future = load()),
            ),
          );
        }
        final game = snap.data!;
        final participants = (game['participants'] as List? ?? []).cast<Map<String, dynamic>>();
        final teams = <int, List<Map<String, dynamic>>>{};
        for (final p in participants) {
          final teamId = (p['teamId'] ?? 0) as int;
          teams.putIfAbsent(teamId, () => []).add(p);
        }
        return ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LIVE GAME FOUND', style: TextStyle(color: RiftTheme.accent, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('Game mode: ${game['gameMode'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
            Text('Map ID: ${game['mapId'] ?? '—'} · Queue ID: ${game['gameQueueConfigId'] ?? '—'}', style: const TextStyle(color: RiftTheme.muted, fontSize: 12)),
          ])),
          const SizedBox(height: 16),
          ...teams.entries.map((entry) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.key == 100 ? 'Blue team' : entry.key == 200 ? 'Red team' : 'Team ${entry.key}', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...entry.value.map((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
              FutureBuilder<String?>(
                future: DDragonService().championIconForKey(p['championId'] ?? 0),
                builder: (context, iconSnap) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: iconSnap.data == null
                      ? const SizedBox(width: 38, height: 38, child: Icon(Icons.shield, size: 30))
                      : Image.network(iconSnap.data!, width: 38, height: 38, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 34)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(p['riotId']?.toString() ?? p['summonerName']?.toString() ?? 'Player', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('Level ${p['summonerLevel'] ?? '—'}', style: const TextStyle(color: RiftTheme.muted, fontSize: 11)),
            ]))),
          ]))),
          const Text('Live-game visibility and participant fields depend on Riot Spectator API availability.', style: TextStyle(color: RiftTheme.muted, fontSize: 11)),
        ]);
      },
    ),
  );
}
