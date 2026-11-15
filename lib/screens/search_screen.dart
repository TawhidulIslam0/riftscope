import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/regions.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';
import 'summoner_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final name = TextEditingController();
  final tag = TextEditingController();
  String region = 'NA';
  bool busy = false;
  String? error;

  Future<void> search() async {
    final gameName = name.text.trim();
    final tagLine = tag.text.trim().replaceFirst('#', '');
    if (gameName.isEmpty || tagLine.isEmpty) {
      setState(() => error = 'Enter both parts of the Riot ID: GameName and TagLine.');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      final r = regionByCode(region);
      final account = await ApiClient().getMap('/api/account/${r.routing}/${Uri.encodeComponent(gameName)}/${Uri.encodeComponent(tagLine)}');
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SummonerScreen(account: account, region: r)));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() { name.dispose(); tag.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 28), children: [
    const Text('Players', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
    const SizedBox(height: 7),
    const Text('Search a player using their current Riot ID.', style: TextStyle(color: RiftTheme.muted)),
    const SizedBox(height: 24),
    const Text('Riot ID', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 9),
    Row(children: [
      Expanded(flex: 3, child: TextField(controller: name, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'GameName'))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('#', style: TextStyle(color: RiftTheme.gold, fontSize: 20, fontWeight: FontWeight.w900))),
      Expanded(flex: 2, child: TextField(controller: tag, textInputAction: TextInputAction.search, onSubmitted: (_) => search(), decoration: const InputDecoration(hintText: 'TAG'))),
    ]),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(
      value: region,
      decoration: const InputDecoration(labelText: 'Platform region'),
      items: regions.map((r) => DropdownMenuItem(value: r.code, child: Text('${r.code} · ${r.label}'))).toList(),
      onChanged: (v) => setState(() => region = v ?? 'NA'),
    ),
    const SizedBox(height: 16),
    SizedBox(height: 52, child: FilledButton.icon(onPressed: busy ? null : search, icon: busy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search), label: Text(busy ? 'Searching Riot API…' : 'Search player'))),
    if (error != null) ...[const SizedBox(height: 16), ErrorPanel(error!)],
    const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(15)), child: const Text('Tip: Riot IDs use the format GameName#TagLine. Your selected platform is used for ranked and match data; account lookup uses Riot regional routing.', style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 12))),
  ]);
}
