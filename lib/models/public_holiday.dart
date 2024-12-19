class PublicHoliday {
  final DateTime date;
  final String localName;
  final String name;
  final String countryCode;
  final bool fixed;
  final bool global;
  final List<String> types;

  PublicHoliday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    required this.fixed,
    required this.global,
    required this.types,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      date: DateTime.parse(json['date']),
      localName: json['localName'],
      name: json['name'],
      countryCode: json['countryCode'],
      fixed: json['fixed'],
      global: json['global'],
      types: List<String>.from(json['types']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'localName': localName,
      'name': name,
      'countryCode': countryCode,
      'fixed': fixed,
      'global': global,
      'types': types,
    };
  }
}
