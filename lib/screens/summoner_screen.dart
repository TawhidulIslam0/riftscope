import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/ddragon_service.dart';
import '../core/formatters.dart';
import '../core/regions.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';
import '../widgets/section_title.dart';
import 'match_detail_screen.dart';
import 'live_game_screen.dart';

class SummonerScreen extends StatefulWidget {
  final Map<String, dynamic> account;
  final RegionInfo region;
  const SummonerScreen({super.key, required this.account, required this.region});
  @override
  State<SummonerScreen> createState() => _SummonerScreenState();
}

class _SummonerScreenState extends State<SummonerScreen> {
  late Future<Map<String, dynamic>> future;
  @override
  void initState() { super.initState(); future = load(); }
  Future<Map<String, dynamic>> load() async {
    final puuid = widget.account['puuid'];
    final api = ApiClient();
    await DDragonService().initialize();
    final results = await Future.wait([
      api.getMap('/api/summoner/${widget.region.platform}/$puuid'),
      api.getList('/api/league/${widget.region.platform}/$puuid'),
      api.getList('/api/matches/${widget.region.routing}/$puuid?start=0&count=10'),
    ]);
    return {'summoner': results[0], 'leagues': results[1], 'matches': results[2]};
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.account['gameName']}#${widget.account['tagLine']}')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingPanel();
        if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(20), child: ErrorPanel(snapshot.error.toString(), onRetry: () => setState(() => future = load())));
        final data = snapshot.data!;
        final summoner = data['summoner'] as Map<String, dynamic>;
        final leagues = data['leagues'] as List;
        final matches = data['matches'] as List;
        return ListView(padding: const EdgeInsets.all(18), children: [
          Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(18)), child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(DDragonService().profileIcon((summoner['profileIconId'] ?? 0) as int), width: 76, height: 76, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 70))),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.account['gameName']}#${widget.account['tagLine']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('Level ${summoner['summonerLevel'] ?? '—'} · ${widget.region.code}', style: const TextStyle(color: RiftTheme.muted)),
              const SizedBox(height: 5),
              Text('Updated ${DateTime.now().toLocal().toString().substring(0, 16)}', style: const TextStyle(color: RiftTheme.muted, fontSize: 10)),
            ])),
          ])),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveGameScreen(region: widget.region, puuid: widget.account['puuid'].toString(), playerName: '${widget.account['gameName']}#${widget.account['tagLine']}'))),
            icon: const Icon(Icons.sensors),
            label: const Text('Check live game'),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Ranked queues'),
          const SizedBox(height: 10),
          if (leagues.isEmpty) const _EmptyCard('No ranked entries were returned for this player.'),
          ...leagues.map((entry) => _RankCard(entry: entry as Map<String, dynamic>)),
          const SizedBox(height: 22),
          SectionTitle('Recent matches', trailing: '${matches.length} loaded'),
          const SizedBox(height: 10),
          if (matches.isEmpty) const _EmptyCard('No match IDs were returned for this player.'),
          ...matches.map((id) => _MatchLoader(matchId: id.toString(), region: widget.region, puuid: widget.account['puuid'].toString())),
        ]);
      },
    ),
  );
}

class _RankCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _RankCard({required this.entry});
  @override
  Widget build(BuildContext context) {
    final wins = (entry['wins'] ?? 0) as int;
    final losses = (entry['losses'] ?? 0) as int;
    final total = wins + losses;
    final rate = total == 0 ? 0 : (wins * 100 / total).round();
    return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(15)), child: Row(children: [
      const Icon(Icons.military_tech, color: RiftTheme.gold, size: 31), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry['queueType'] == 'RANKED_SOLO_5x5' ? 'Ranked Solo/Duo' : entry['queueType'] == 'RANKED_FLEX_SR' ? 'Ranked Flex' : safeString(entry['queueType']), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${safeString(entry['tier'])} ${safeString(entry['rank'])} · ${entry['leaguePoints'] ?? 0} LP', style: const TextStyle(color: RiftTheme.gold, fontSize: 12)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$rate%', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('$wins W  $losses L', style: const TextStyle(color: RiftTheme.muted, fontSize: 10))]),
    ]));
  }
}

class _MatchLoader extends StatelessWidget {
  final String matchId; final RegionInfo region; final String puuid;
  const _MatchLoader({required this.matchId, required this.region, required this.puuid});
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: ApiClient().getMap('/api/match/${region.routing}/$matchId'),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
      if (snapshot.hasError) return const SizedBox.shrink();
      final info = snapshot.data!['info'] as Map<String, dynamic>? ?? {};
      final participants = (info['participants'] as List? ?? []);
      final player = participants.cast<Map<String, dynamic>?>().firstWhere((p) => p?['puuid'] == puuid, orElse: () => null);
      if (player == null) return const SizedBox.shrink();
      return _MatchCard(match: snapshot.data!, player: player, region: region);
    },
  );
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match; final Map<String, dynamic> player; final RegionInfo region;
  const _MatchCard({required this.match, required this.player, required this.region});
  @override
  Widget build(BuildContext context) {
    final win = player['win'] == true;
    final k = player['kills'] ?? 0; final d = player['deaths'] ?? 0; final a = player['assists'] ?? 0;
    final info = match['info'] as Map<String, dynamic>;
    final seconds = (info['gameDuration'] ?? 0) as int;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(match: match, region: region))),
      child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(14), border: Border(left: BorderSide(color: win ? RiftTheme.accent : const Color(0xFFE45D6A), width: 3))), child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(DDragonService().championIcon(player['championName'].toString()), width: 49, height: 49, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40))),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(player['championName']?.toString() ?? 'Unknown champion', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('$k / $d / $a  ·  ${duration(seconds)}', style: const TextStyle(color: RiftTheme.muted, fontSize: 12)),
          Text('${player['gameMode'] ?? info['gameMode'] ?? 'League'} · ${player['totalMinionsKilled'] ?? 0} CS', style: const TextStyle(color: RiftTheme.muted, fontSize: 10)),
        ])),
        Text(win ? 'VICTORY' : 'DEFEAT', style: TextStyle(color: win ? RiftTheme.accent : const Color(0xFFE45D6A), fontWeight: FontWeight.w900, fontSize: 10)),
      ])),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard(this.message);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(14)), child: Text(message, style: const TextStyle(color: RiftTheme.muted)));
}
