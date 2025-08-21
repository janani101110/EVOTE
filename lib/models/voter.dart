class ApiException implements Exception {
  final int? status;
  final String message;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class VoterDto {
  final int id;
  final String nic;
  final String fullName;
  final String divisionCode;
  final bool? hasVoted; // optional (backend VoterResponse currently doesn't include it)

  VoterDto({
    required this.id,
    required this.nic,
    required this.fullName,
    required this.divisionCode,
    this.hasVoted,
  });

  factory VoterDto.fromJson(Map<String, dynamic> json) {
    return VoterDto(
      id: (json['id'] as num).toInt(),
      nic: json['nic'] as String,
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      divisionCode: (json['divisionCode'] ?? json['division'] ?? '') as String,
      hasVoted: json['hasVoted'] is bool ? json['hasVoted'] as bool : null,
    );
  }
}