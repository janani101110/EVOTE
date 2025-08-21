import 'package:evote/models/results.dart';
import 'package:evote/services/admin/adminResultservice.dart';
import 'package:evote/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';


class Adminresults extends StatefulWidget {
  const Adminresults({super.key});
  @override
  State<Adminresults> createState() => _AdminresultsState();
}

class _AdminresultsState extends State<Adminresults> {
  final _service = ResultsService(baseUrl: baseUrl);

  String? _token;
  String? _role;

  bool _loading = true;
  String? _error;

  ElectionResult? _data;

  bool get _isSuperAdmin => _role == 'SUPER_ADMIN';

  static const firstpref = Color(0xFF6F2C91);
  static const secpref = Color(0xFF2CA58D);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('admin_jwt');
    _role = p.getString('admin_role');

    if (_token == null || _token!.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated. Please login.';
      });
      return;
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _service.electionResults(token: _token!);
      setState(() => _data = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _winnerName(PreferenceResult r) {
    if (r.winnerId == null) return '—';
    final all = [...r.firstPref, ...r.secondPref];
    final hit = all.firstWhere(
      (c) => c.id == r.winnerId,
      orElse: () => CountItem(id: r.winnerId!, name: 'Winner #${r.winnerId}', count: 0),
    );
    return hit.name;
  }

  // Shorten long candidate names for x-axis labels
  String _short(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return name.length > 10 ? '${name.substring(0, 10)}…' : name;
    final first = parts.first;
    final last = parts.last;
    final s = '${first} ${last.isNotEmpty ? last[0] : ''}.';
    return s.length > 14 ? '${s.substring(0, 14)}…' : s;
  }

 Widget _overallCard(PreferenceResult r) {
  final first = r.firstPref;
  final second = r.secondPref;

    final ids = <int>[];
    for (final c in first) {
      if (!ids.contains(c.id)) ids.add(c.id);
    }
    for (final c in second) {
      if (!ids.contains(c.id)) ids.add(c.id);
    }

    final map1 = {for (final c in first) c.id: c.count};
    final map2 = {for (final c in second) c.id: c.count};
    final nameById = {
      for (final c in [...first, ...second]) c.id: c.name,
    };

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < ids.length; i++) {
      final id = ids[i];
      final v1 = (map1[id] ?? 0).toDouble();
      final v2 = (map2[id] ?? 0).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: v1,color: firstpref),
            BarChartRodData(toY: v2,color: secpref),
          ],
          barsSpace: 6,
        ),
      );
    }

    final maxY = [
      ...first.map((e) => e.count),
      ...second.map((e) => e.count),
      1
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Winner
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 28),
              const SizedBox(width: 8),
              Text(
                'Overall Winner By First Preference: ${_winnerName(r)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart Title
          Row(
            children: const [
              Text('First vs Second Preferences',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),

          // Grouped Bar Chart
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxY * 1.2),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: groups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= ids.length) return const SizedBox();
                        final label = _short(nameById[ids[i]] ?? '');
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Transform.rotate(
                            angle: -0.6, // tilt for readability
                            child: Text(label, style: const TextStyle(fontSize: 11)),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(label: 'First Pref',color: firstpref,),
              SizedBox(width: 16),
              _LegendDot(label: 'Second Pref',color: secpref,),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Sorted totals table
          _totalsTable(first, second),
        ],
      ),
    );
  }

  Widget _totalsTable(List<CountItem> first, List<CountItem> second) {
    final map1 = {for (final c in first) c.id: c};
    final map2 = {for (final c in second) c.id: c};
    final ids = {
      ...map1.keys,
      ...map2.keys,
    }.toList();

    final rows = ids.map((id) {
      final c1 = map1[id];
      final c2 = map2[id];
      final name = c1?.name ?? c2?.name ?? 'Candidate #$id';
      final f = c1?.count ?? 0;
      final s = c2?.count ?? 0;
      final total = f + s;
      return {'id': id, 'name': name, 'f': f, 's': s, 't': total};
    }).toList();

    rows.sort((a, b) => (b['t'] as int).compareTo(a['t'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Totals', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => Colors.grey[200],
            ),
            columns: const [
              DataColumn(label: Text('Candidate')),
              DataColumn(label: Text('First')),
              DataColumn(label: Text('Second')),
              DataColumn(label: Text('Total')),
            ],
            rows: rows
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text(r['name'] as String)),
                      DataCell(Text('${r['f']}')),
                      DataCell(Text('${r['s']}')),
                      DataCell(Text('${r['t']}')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _divisionTile(DivisionResult d) {
    final r = d.result;
    final first = r.firstPref;
    if (first.isEmpty) {
      return ExpansionTile(
        title: Text('${d.divisionName} • No data'),
        children: const [SizedBox.shrink()],
      );
    }

    final maxY = first.map((e) => e.count).fold<int>(1, (m, v) => v > m ? v : m).toDouble();

    return ExpansionTile(
      title: Text(d.divisionName),
      subtitle: Text('Winner: ${_winnerName(r)}'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.2,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= first.length) return const SizedBox();
                      final label = _short(first[i].name);
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Transform.rotate(
                          angle: -0.6,
                          child: Text(label, style: const TextStyle(fontSize: 11)),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(
                first.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(toY: first[i].count.toDouble())],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                height: 88,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Election Results',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              else if (!_isSuperAdmin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Forbidden. SUPER_ADMIN only.'),
                )
              else if (_data == null)
                const SizedBox()
              else ...[
                // Overall
                _overallCard(_data!.overall),
                const SizedBox(height: 20),

                // Division-wise
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Division Breakdown',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ..._data!.divisionResults.map(_divisionTile),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
