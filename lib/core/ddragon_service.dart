import 'dart:convert';
import 'package:http/http.dart' as http;

class DDragonService {
  static const _root = 'https://ddragon.leagueoflegends.com';
  String? _version;
  static String? _sharedVersion;
  Map<String, dynamic>? _champions;
  Map<String, dynamic>? _items;
  Map<String, dynamic>? _runes;
  Map<String, dynamic>? _spells;

  String get version => _version ?? _sharedVersion ?? 'latest';
  String championIcon(String id) => '$_root/cdn/$version/img/champion/$id.png';
  String itemIcon(String id) => '$_root/cdn/$version/img/item/$id.png';
  String spellIcon(String image) => '$_root/cdn/$version/img/spell/$image';
  String profileIcon(int id) => '$_root/cdn/$version/img/profileicon/$id.png';

  Future<void> initialize() async {
    if (_version != null) return;
    final versionsResponse = await http.get(Uri.parse('$_root/api/versions.json'));
    if (versionsResponse.statusCode != 200) throw Exception('Could not load Data Dragon versions.');
    final versions = jsonDecode(versionsResponse.body) as List;
    if (versions.isEmpty) throw Exception('Data Dragon did not return a version.');
    _version = versions.first.toString();
    _sharedVersion = _version;
  }

  Future<Map<String, dynamic>> _load(String path) async {
    await initialize();
    final response = await http.get(Uri.parse('$_root/cdn/$_version/data/en_US/$path'));
    if (response.statusCode != 200) throw Exception('Data Dragon request failed (${response.statusCode}).');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> champions() async {
    _champions ??= (await _load('champion.json'))['data'] as Map<String, dynamic>;
    return _champions!;
  }

  Future<Map<String, dynamic>> items() async {
    _items ??= (await _load('item.json'))['data'] as Map<String, dynamic>;
    return _items!;
  }

  Future<List<dynamic>> runes() async {
    await initialize();
    if (_runes == null) {
      final response = await http.get(Uri.parse('$_root/cdn/$_version/data/en_US/runesReforged.json'));
      if (response.statusCode != 200) throw Exception('Data Dragon rune request failed (${response.statusCode}).');
      final decoded = jsonDecode(response.body);
      if (decoded is! List) throw Exception('Unexpected Data Dragon rune format.');
      _runes = {'entries': decoded};
    }
    return _runes!['entries'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> spells() async {
    _spells ??= (await _load('summoner.json'))['data'] as Map<String, dynamic>;
    return _spells!;
  }

  Future<Map<String, dynamic>> championDetail(String id) async {
    final data = await _load('champion/$id.json');
    return (data['data'] as Map<String, dynamic>)[id] as Map<String, dynamic>;
  }

  Future<String?> championIconForKey(dynamic championKey) async {
    final all = await champions();
    for (final champion in all.values) {
      if (champion['key']?.toString() == championKey.toString()) {
        return championIcon(champion['id'].toString());
      }
    }
    return null;
  }
}
