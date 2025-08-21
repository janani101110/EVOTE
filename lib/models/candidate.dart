class ApiException implements Exception {
  final int? status;
  final String message;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class CandidateDto {
  final int id;
  final String name;
  final String party;
  final String candidateCode;

  CandidateDto({
    required this.id,
    required this.name,
    required this.party,
    required this.candidateCode,
  });

  /// Flexible mapping: backend may send candidateName/partyName or name/party.
  factory CandidateDto.fromJson(Map<String, dynamic> json) {
    String pick(Map<String, dynamic> j, String a, String b) =>
        (j[a] ?? j[b] ?? '') as String;

    return CandidateDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: pick(json, 'candidateName', 'name'),
      party: pick(json, 'partyName', 'party'),
      candidateCode: (json['candidateCode'] ?? '') as String,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'party': party,
        'candidateCode': candidateCode,
      };
}