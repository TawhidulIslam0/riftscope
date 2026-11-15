class RegionInfo {
  final String code;
  final String label;
  final String platform;
  final String routing;
  const RegionInfo(this.code, this.label, this.platform, this.routing);
}

const regions = <RegionInfo>[
  RegionInfo('NA', 'North America', 'na1', 'americas'),
  RegionInfo('EUW', 'Europe West', 'euw1', 'europe'),
  RegionInfo('EUNE', 'Europe Nordic & East', 'eun1', 'europe'),
  RegionInfo('KR', 'Korea', 'kr', 'asia'),
  RegionInfo('BR', 'Brazil', 'br1', 'americas'),
  RegionInfo('JP', 'Japan', 'jp1', 'asia'),
  RegionInfo('LAN', 'Latin America North', 'la1', 'americas'),
  RegionInfo('LAS', 'Latin America South', 'la2', 'americas'),
  RegionInfo('OCE', 'Oceania', 'oc1', 'sea'),
  RegionInfo('TR', 'Turkey', 'tr1', 'europe'),
  RegionInfo('RU', 'Russia', 'ru', 'europe'),
  RegionInfo('PH', 'Philippines', 'ph2', 'sea'),
  RegionInfo('SG', 'Singapore', 'sg2', 'sea'),
  RegionInfo('TH', 'Thailand', 'th2', 'sea'),
  RegionInfo('TW', 'Taiwan', 'tw2', 'sea'),
  RegionInfo('VN', 'Vietnam', 'vn2', 'sea'),
];

RegionInfo regionByCode(String code) =>
    regions.firstWhere((r) => r.code == code, orElse: () => regions.first);
