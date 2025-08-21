import 'dart:async';
import 'package:evote/services/admin/adminDshboardservice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:evote/widget/piechart.dart';

const FirstPrefColor = Color(0xFF6F2C91); // purple
const SecondPrefColor = Color(0xFF2CA58D); // teal

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  final _svc = AdminDashboardService();
  Timer? _poller;

  DashboardData? _data;
  String? _token;
  String? _role;

  // countdown
  String currentPhase = 'Voting';
  DateTime? phaseEndTime;

  // --- analytics (client-side only) ---
  final List<_Point> _turnoutHistory = [];
  final Map<String, int> _lastTotals = {};
  List<_Mover> _topMovers = [];

  bool get _isSuperAdmin => _role == 'SUPER_ADMIN';

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  Future<void> _bootstrap() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('admin_jwt');
    _role = p.getString('admin_role');

    // start polling if authenticated
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated. Please login.')),
      );
      return;
    }

    // immediate load
    await _loadOnce();

    // poll every 5 seconds
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _loadOnce());
  }

  Future<void> _loadOnce() async {
    try {
      final d = await _svc.load(token: _token!);
      setState(() {
        final now = DateTime.now();

        // prepare movers using previous snapshot
        final currentTotals = <String, int>{};
        for (final r in d.leaderboard) {
          currentTotals[r.name] = r.total;
        }
        final movers = <_Mover>[];
        currentTotals.forEach((name, totalNow) {
          final prev = _lastTotals[name] ?? totalNow;
          final delta = totalNow - prev;
          if (delta > 0) movers.add(_Mover(name, delta));
        });
        movers.sort((a, b) => b.delta.compareTo(a.delta));
        final top3 = movers.take(3).toList();

        // update analytics state
        _turnoutHistory.add(_Point(now, d.votesCast));
        // keep only last 30 minutes of samples
        _turnoutHistory.removeWhere(
          (p) => now.difference(p.t) > const Duration(minutes: 30),
        );
        // remember this snapshot for next diff
        _lastTotals
          ..clear()
          ..addAll(currentTotals);

        setState(() {
          _data = d;
          _topMovers = top3;

          // keep your existing fallback phase handling if you still want it for display
          if (d.phaseStatus != null) {
            currentPhase = d.phaseStatus!.phase;
            phaseEndTime = d.phaseStatus!.phaseEndTime;
          } else {
            phaseEndTime ??= DateTime(2025, 6, 30, 17, 0, 0);
          }
        });
      });
    } catch (e) {
      // show once; don't spam
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh dashboard: $e')),
        );
      }
    }
  }

  // void _updateCountdown() {
  //   if (phaseEndTime == null) return;
  //   final diff = phaseEndTime!.difference(DateTime.now());
  //   setState(() {
  //     timeLeft = diff.isNegative ? Duration.zero : diff;
  //     if (diff.isNegative) currentPhase = 'Counting';
  //   });
  // }

  @override
  void dispose() {
    _poller?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalVoters = _data?.totalVoters ?? 0;
    final votesCast = _data?.votesCast ?? 0;
    final leaderboard = _data?.leaderboard ?? const <LeaderboardRow>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header/status
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Current Election Status',
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 50),

                  _LiveBadge(isLive: true),
                  const Spacer(),
                  SizedBox(
                    height: double.infinity,
                    child: Image.asset(
                      'assets/bannerimg.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Three columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie chart (live turnout)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(253, 249, 249, 250),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF7E57C2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Voter Turnout',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 26, 1, 123),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MiniStats(total: totalVoters, cast: votesCast),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 350,
                        width: 350,
                        child: Piechart(
                          totalVoters: totalVoters,
                          votesCast: votesCast,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Middle column: Trend + Movers
                SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TurnoutTrendCard(history: _turnoutHistory),
                      const SizedBox(height: 16),
                      _TopMoversCard(movers: _topMovers),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Leaderboard (live)
                Container(
                  width: 350,
                  height: 500,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF7E57C2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Leader Board',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 26, 1, 123),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            leaderboard.isEmpty
                                ? const Center(child: Text('No data yet'))
                                : ListView.separated(
                                  itemCount: leaderboard.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(
                                        color: Color.fromARGB(
                                          255,
                                          134,
                                          130,
                                          130,
                                        ),
                                      ),
                                  itemBuilder: (context, i) {
                                    final row = leaderboard[i];
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.how_to_vote,
                                          color: Color.fromARGB(
                                            255,
                                            26,
                                            1,
                                            123,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            row.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                134,
                                                130,
                                                130,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _Badge(
                                          label: '1st',
                                          value: row.first,
                                          color: FirstPrefColor,
                                        ),
                                        const SizedBox(width: 6),
                                        _Badge(
                                          label: '2nd',
                                          value: row.second,
                                          color: SecondPrefColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${row.total}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                              255,
                                              134,
                                              130,
                                              130,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLive;
  const _LiveBadge({required this.isLive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isLive
                ? const Color.fromARGB(255, 173, 255, 176)
                : Colors.grey[300],
      ),
      child: Row(
        children: [
          Icon(
            Icons.podcasts,
            color:
                isLive
                    ? const Color.fromARGB(194, 2, 124, 8)
                    : Colors.grey[700],
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'Live' : 'Paused',
            style: TextStyle(
              color:
                  isLive
                      ? const Color.fromARGB(194, 2, 124, 8)
                      : Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnoutTrendCard extends StatelessWidget {
  final List<_Point> history;
  const _TurnoutTrendCard({required this.history});

  int _deltaLast(Duration window) {
    if (history.length < 2) return 0;
    final last = history.last;
    final cutoff = last.t.subtract(window);
    _Point? firstInWindow;
    for (var i = history.length - 1; i >= 0; i--) {
      if (history[i].t.isBefore(cutoff)) break;
      firstInWindow = history[i];
    }
    firstInWindow ??= history.first;
    return last.v - firstInWindow.v;
  }

  @override
  Widget build(BuildContext context) {
    final delta5m = _deltaLast(const Duration(minutes: 5));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7E57C2)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Turnout Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 26, 1, 123),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Polling every 5s',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7E57C2)),
                ),
              ),
              const Spacer(),
              Text(
                'Last 5 min: ${delta5m >= 0 ? '+' : ''}$delta5m',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      delta5m >= 0 ? const Color(0xFF2CA58D) : Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: _Sparkline(history: history),
          ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<_Point> history;
  const _Sparkline({required this.history});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(history), child: Container());
  }
}

class _SparklinePainter extends CustomPainter {
  final List<_Point> history;
  _SparklinePainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    // bounds
    final minV = history.map((e) => e.v).reduce((a, b) => a < b ? a : b);
    var maxV = history.map((e) => e.v).reduce((a, b) => a > b ? a : b);
    if (maxV == minV) maxV = minV + 1;

    final dx = size.width / (history.length - 1).clamp(1, 999999);
    final path = Path();

    for (int i = 0; i < history.length; i++) {
      final x = i * dx;
      final yNorm = (history[i].v - minV) / (maxV - minV);
      final y = size.height - (yNorm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paintLine =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = const Color(0xFF7E57C2);
    canvas.drawPath(path, paintLine);

    // fill area
    final fillPath =
        Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
    final paintFill =
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF7E57C2).withOpacity(0.12);
    canvas.drawPath(fillPath, paintFill);

    // last point dot
    final lastX = (history.length - 1) * dx;
    final lastYNorm = (history.last.v - minV) / (maxV - minV);
    final lastY = size.height - (lastYNorm * size.height);
    final dot = Paint()..color = const Color(0xFF2CA58D);
    canvas.drawCircle(Offset(lastX, lastY), 3.5, dot);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.history != history;
}

class _TopMoversCard extends StatelessWidget {
  final List<_Mover> movers;
  const _TopMoversCard({required this.movers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7E57C2)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Movers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 26, 1, 123),
            ),
          ),
          const SizedBox(height: 8),
          if (movers.isEmpty)
            const Text(
              'No changes yet',
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              children:
                  movers.map((m) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 18,
                            color: Color(0xFF2CA58D),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2CA58D).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${m.delta}',
                              style: const TextStyle(
                                color: Color(0xFF2CA58D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}

// --- tiny models for client-side analytics ---
class _Point {
  final DateTime t;
  final int v;
  const _Point(this.t, this.v);
}

class _Mover {
  final String name;
  final int delta;
  const _Mover(this.name, this.delta);
}

class _MiniStats extends StatelessWidget {
  final int total;
  final int cast;
  const _MiniStats({required this.total, required this.cast});
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((cast / total) * 100).clamp(0, 100);
    return Row(
      children: [
        _Kpi(title: 'Total Voters', value: total.toString()),
        const SizedBox(width: 16),
        _Kpi(title: 'Votes Cast', value: cast.toString()),
        const SizedBox(width: 16),
        _Kpi(title: 'Turnout', value: '${pct.toStringAsFixed(1)}%'),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String title;
  final String value;
  const _Kpi({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Badge({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
