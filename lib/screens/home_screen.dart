import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/section_title.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
    children: [
      Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: RiftTheme.accent.withOpacity(.15), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt, color: RiftTheme.accent)),
        const SizedBox(width: 11),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RIFTSCOPE', style: TextStyle(fontSize: 12, letterSpacing: 2.2, color: RiftTheme.accent, fontWeight: FontWeight.w900)),
          Text('League companion', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        ]),
        const Spacer(),
        const Icon(Icons.sports_esports, color: RiftTheme.gold),
      ]),
      const SizedBox(height: 26),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF173C4B), Color(0xFF17213A), Color(0xFF241E37)]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR RIFT, YOUR DATA', style: TextStyle(color: RiftTheme.gold, letterSpacing: 1.4, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Know the game.\nPlay with purpose.', style: TextStyle(fontSize: 27, height: 1.12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Look up real player profiles, match history and champion information.', style: TextStyle(color: Colors.white70, height: 1.45)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
            icon: const Icon(Icons.search),
            label: const Text('Find a player'),
          ),
        ]),
      ),
      const SizedBox(height: 26),
      const SectionTitle('Explore the Rift'),
      const SizedBox(height: 12),
      _ExploreTile(icon: Icons.person_search, title: 'Summoner search', subtitle: 'Riot ID, rank and match history', color: const Color(0xFF13B8A6), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()))),
      const SizedBox(height: 10),
      const _InfoTile(icon: Icons.shield_outlined, title: 'Champion database', subtitle: 'Abilities, stats and official game art'),
      const SizedBox(height: 10),
      const _InfoTile(icon: Icons.auto_awesome, title: 'Items & runes', subtitle: 'Current Data Dragon game data'),
      const SizedBox(height: 24),
      const SectionTitle('Data transparency'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: const Text(
          'Player statistics come from Riot Games APIs. Champion, item and rune descriptions come from Riot Data Dragon. No sample player profiles or invented match statistics are shown.',
          style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
        ),
      ),
      const SizedBox(height: 16),
      const Text('Unofficial fan project. Not endorsed by Riot Games.', style: TextStyle(color: RiftTheme.muted, fontSize: 11)),
    ],
  );
}

class _ExploreTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ExploreTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(16),
    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: RiftTheme.muted, fontSize: 12))])),
        const Icon(Icons.chevron_right, color: RiftTheme.muted),
      ]),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(16)), child: Row(children: [
    Icon(icon, color: RiftTheme.gold, size: 25), const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: RiftTheme.muted, fontSize: 12))])),
  ]));
}
