import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class Piechart extends StatelessWidget {
  final int totalVoters;
  final int votesCast;

  const Piechart({
    super.key,
    required this.totalVoters,
    required this.votesCast ,
  });

  @override
  Widget build(BuildContext context) {
    final dataMap = {
      "Votes Cast": votesCast.toDouble(),
      "Not Voted": (totalVoters - votesCast).toDouble(),
    };

    return SizedBox(
      height: 300,
      width: 400,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartRadius: 200,
        colorList: [const Color.fromARGB(255, 250, 147, 12), Colors.grey.shade300],
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
