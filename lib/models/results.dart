class ApiException implements Exception {
  final int? status;
  final String message;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}
Map<String, dynamic> _asMap(dynamic v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};

List<Map<String, dynamic>> _asListOfMap(dynamic v) =>
    v is List ? v.whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];

int? _asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

String _asString(dynamic v) => v?.toString() ?? '';

class CountItem {
  final int id;
  final String name;
  final int count;
  CountItem({required this.id, required this.name, required this.count});

  factory CountItem.fromAny(Map<String, dynamic> j) => CountItem(
        id: _asIntOrNull(j['id'] ?? j['candidateId']) ?? 0,
        name: _asString(j['name'] ?? j['candidateName']),
        count: _asIntOrNull(j['count']) ?? 0,
      );
}

class PreferenceResult {
  final List<CountItem> firstPref;
  final List<CountItem> secondPref;
  final int? winnerId;

  PreferenceResult({
    required this.firstPref,
    required this.secondPref,
    required this.winnerId,
  });

  factory PreferenceResult.fromAny(dynamic any) {
    final j = _asMap(any);
    final firstRaw = _asListOfMap(j['firstPref'] ?? j['firstPreferences']);
    final secondRaw = _asListOfMap(j['secondPref'] ?? j['secondPreferences']);
    return PreferenceResult(
      firstPref: firstRaw.map(CountItem.fromAny).toList(),
      secondPref: secondRaw.map(CountItem.fromAny).toList(),
      winnerId: _asIntOrNull(j['winnerId']),
    );
  }

  static PreferenceResult empty() =>
      PreferenceResult(firstPref: const [], secondPref: const [], winnerId: null);
}

class DivisionResult {
  final int divisionId;
  final String divisionName;
  final PreferenceResult result;

  DivisionResult({
    required this.divisionId,
    required this.divisionName,
    required this.result,
  });

  factory DivisionResult.fromAny(Map<String, dynamic> j) => DivisionResult(
        divisionId: _asIntOrNull(j['divisionId']) ?? 0,
        divisionName: _asString(j['divisionName']),
        result: PreferenceResult.fromAny(j['candidateResults']),
      );
}

class ElectionResult {
  final PreferenceResult overall;
  final List<DivisionResult> divisionResults;

  ElectionResult({required this.overall, required this.divisionResults});

  factory ElectionResult.fromAny(dynamic any) {
    final j = _asMap(any);
    final overall = j.containsKey('overallResult')
        ? PreferenceResult.fromAny(j['overallResult'])
        : PreferenceResult.empty();

    final divsRaw = j['divisionResults'];
    final divs = _asListOfMap(divsRaw).map(DivisionResult.fromAny).toList();

    return ElectionResult(overall: overall, divisionResults: divs);
  }
}
