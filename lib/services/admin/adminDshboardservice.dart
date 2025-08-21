// lib/services/admin/admin_dashboard_service.dart
import 'dart:convert';
import 'package:evote/services/admin/adminResultservice.dart';
import 'package:evote/services/admin/adminVoterservice.dart';
import 'package:http/http.dart' as http;
import 'package:evote/services/services.dart' show baseUrl;

class DashboardApiException implements Exception {
  final int? status;
  final String message;
  DashboardApiException(this.message, {this.status});
  @override
  String toString() => 'DashboardApiException($status): $message';
}

class LeaderboardRow {
  final int candidateId;
  final String name;
  final int first;
  final int second;
  int get total => first + second;
  LeaderboardRow({required this.candidateId, required this.name, required this.first, required this.second});
}

class PhaseStatus {
  final String phase;            // e.g. "Voting", "Counting", "Closed"
  final DateTime? phaseEndTime;  // for countdown
  final String? electionName;
  PhaseStatus({required this.phase, this.phaseEndTime, this.electionName});
}

class DashboardData {
  final int totalVoters;
  final int votesCast;          // derived as sum of first preferences
  final List<LeaderboardRow> leaderboard;
  final PhaseStatus? phaseStatus;
  DashboardData({
    required this.totalVoters,
    required this.votesCast,
    required this.leaderboard,
    required this.phaseStatus,
  });
}

class AdminDashboardService {
  final http.Client _client;
  final String _base;
  final ResultsService _resultsService;
  final VoterService _voterService;

  AdminDashboardService({
    http.Client? client,
    String? base,
    ResultsService? resultsService,
    VoterService? voterService,
  })  : _client = client ?? http.Client(),
        _base = base ?? baseUrl,
        _resultsService = resultsService ?? ResultsService(baseUrl: baseUrl),
        _voterService = voterService ?? VoterService(baseUrl: baseUrl);

  Uri _u(String p) => Uri.parse('$_base$p');

  /// Optional endpoint (if you add one): GET /api/admin/election/status
  /// Expected JSON: { "phase":"Voting","phaseEndTime":"2025-06-30T17:00:00","electionName":"..." }
  Future<PhaseStatus?> _fetchPhaseStatus(String token) async {
    final url = _u('/api/admin/election/status');
    final res = await _client.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      DateTime? end;
      final v = j['phaseEndTime'];
      if (v is String && v.isNotEmpty) {
        end = DateTime.tryParse(v);
      }
      return PhaseStatus(
        phase: (j['phase'] ?? 'Voting').toString(),
        phaseEndTime: end,
        electionName: (j['electionName'] ?? '').toString().isEmpty ? null : j['electionName'].toString(),
      );
    }
    // If endpoint doesn't exist or not authorized, just ignore and return null
    return null;
  }

  Future<DashboardData> load({required String token}) async {
    // fetch election results (overall first/second preferences)
    final results = await _resultsService.electionResults(token: token);
    final overall = results.overall;

    // votesCast = sum of first preferences (each voter casts exactly one first pref)
    final votesCast = overall.firstPref.fold<int>(0, (sum, c) => sum + c.count);

    // totalVoters = count voters (for very large datasets, add a count-only endpoint later)
    final voters = await _voterService.list(token: token);
    final totalVoters = voters.length;

    // build leaderboard by merging first + second per candidate
    final fMap = {for (final c in overall.firstPref) c.id: c};
    final sMap = {for (final c in overall.secondPref) c.id: c};
    final ids = {...fMap.keys, ...sMap.keys}.toList();

    final leaderboard = ids.map((id) {
      final f = fMap[id];
      final s = sMap[id];
      return LeaderboardRow(
        candidateId: id,
        name: (f?.name ?? s?.name ?? 'Candidate #$id'),
        first: f?.count ?? 0,
        second: s?.count ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    // optional phase status
    final phase = await _fetchPhaseStatus(token);

    return DashboardData(
      totalVoters: totalVoters,
      votesCast: votesCast,
      leaderboard: leaderboard,
      phaseStatus: phase,
    );
  }
}
