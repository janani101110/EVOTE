import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class Piechart extends StatelessWidget {
  final int totalVoters;
  final int votesCast;

  const Piechart({
    super.key,
    this.totalVoters = 1000,
    this.votesCast = 750,
  });

  @override
  Widget build(BuildContext context) {
    final dataMap = {
      "Votes Cast": votesCast.toDouble(),
      "Not Voted": (totalVoters - votesCast).toDouble(),
    };

    return SizedBox(
      height: 400,
      width: 400,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartRadius: 300,
        colorList: [Colors.orange, Colors.grey.shade300],
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.bottom,
          showLegends: true,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValuesInPercentage: true,
          showChartValuesOutside: true,
          decimalPlaces: 1,
        ),
      ),
    );
  }
}
