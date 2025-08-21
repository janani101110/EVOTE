class ApiException implements Exception {
  final int? status;
  final String message;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class DivisionDto {
  final int id;
  final String name;
  final String code;

  DivisionDto({required this.id, required this.name, required this.code});

  factory DivisionDto.fromJson(Map<String, dynamic> json) {
    String pick(Map<String, dynamic> j, String a, String b) =>
        (j[a] ?? j[b] ?? '') as String;

    return DivisionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: pick(json, 'divisionName', 'name'),
      code: pick(json, 'divisionCode', 'code'),
    );
  }
}
