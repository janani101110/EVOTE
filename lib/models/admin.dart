class ApiException implements Exception {
  final int? status;
  final String message;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class AdminUserDto {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? divisionId;
  final bool active;

  AdminUserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.active,
    this.divisionId,
  });

  factory AdminUserDto.fromJson(Map<String, dynamic> j) => AdminUserDto(
        id: (j['id'] as num).toInt(),
        fullName: j['fullName'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
        divisionId: j['divisionId'] == null ? null : (j['divisionId'] as num).toInt(),
        active: j['active'] as bool,
      );

  Map<String, dynamic> toCreateJson({
    required String password,
  }) =>
      {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role, // e.g. "SUPER_ADMIN" | "DIVISION_ADMIN"
        'divisionId': divisionId, // may be null
      };
}