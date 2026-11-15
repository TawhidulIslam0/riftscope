import 'package:flutter/material.dart';
import '../core/ddragon_service.dart';
import '../core/theme.dart';
import '../widgets/async_state.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});
  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> with SingleTickerProviderStateMixin {
  final service = DDragonService();
  late final TabController tabs = TabController(length: 3, vsync: this);
  late Future<void> init;
  @override
  void initState() { super.initState(); init = service.initialize(); }
  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    const Padding(padding: EdgeInsets.fromLTRB(20, 22, 20, 12), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Game data', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      SizedBox(height: 7),
      Text('Items, runes and summoner spells from Riot.', style: TextStyle(color: RiftTheme.muted)),
    ]))),
    TabBar(controller: tabs, tabs: const [Tab(text: 'Items'), Tab(text: 'Runes'), Tab(text: 'Spells')]),
    Expanded(child: FutureBuilder<void>(future: init, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const LoadingPanel();
      if (snap.hasError) return ErrorPanel(snap.error.toString());
      return TabBarView(controller: tabs, children: [_ItemsList(service: service), _RunesList(service: service), _SpellsList(service: service)]);
    })),
  ]);
}

class _ItemsList extends StatelessWidget {
  final DDragonService service;
  const _ItemsList({required this.service});
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(future: service.items(), builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const LoadingPanel();
    if (snap.hasError) return ErrorPanel(snap.error.toString());
    final values = snap.data!.entries.where((e) => (e.value['maps']?['11'] == true) && (e.value['gold']?['purchasable'] == true)).toList()
      ..sort((a, b) => ((a.value['name'] ?? '') as String).compareTo((b.value['name'] ?? '') as String));
    return ListView.builder(padding: const EdgeInsets.all(14), itemCount: values.length, itemBuilder: (context, i) {
      final e = values[i]; final item = e.value;
      return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(13)), child: Row(children: [
        Image.network(service.itemIcon(e.key), width: 45, height: 45, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${item['gold']?['total'] ?? 0} gold', style: const TextStyle(color: RiftTheme.gold, fontSize: 11)),
          Text(item['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RiftTheme.muted, fontSize: 10)),
        ])),
      ]));
    });
  });
}

class _RunesList extends StatelessWidget {
  final DDragonService service;
  const _RunesList({required this.service});
  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(future: service.runes(), builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const LoadingPanel();
    if (snap.hasError) return ErrorPanel(snap.error.toString());
    return ListView(padding: const EdgeInsets.all(14), children: snap.data!.map((tree) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tree['name'].toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: RiftTheme.gold)),
      const SizedBox(height: 9),
      ...((tree['slots'] as List).expand((slot) => (slot['runes'] as List).map((rune) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
        Image.network('https://ddragon.leagueoflegends.com/cdn/${service.version}/img/${rune['icon']}', width: 34, height: 34, errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 30)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rune['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)), Text(rune['longDesc'].toString().replaceAll(RegExp(r'<[^>]*>'), ''), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RiftTheme.muted, fontSize: 10))])),
      ]))))),
    ]))).toList());
  });
}

class _SpellsList extends StatelessWidget {
  final DDragonService service;
  const _SpellsList({required this.service});
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(future: service.spells(), builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const LoadingPanel();
    if (snap.hasError) return ErrorPanel(snap.error.toString());
    final values = snap.data!.values.toList()..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    return ListView(padding: const EdgeInsets.all(14), children: values.map((s) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: RiftTheme.surface, borderRadius: BorderRadius.circular(13)), child: Row(children: [
      Image.network(service.spellIcon(s['image']['full']), width: 42, height: 42, errorBuilder: (_, __, ___) => const Icon(Icons.flash_on)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)), Text(s['description'].toString().replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: RiftTheme.muted, fontSize: 11))])),
    ]))).toList());
  });
}
