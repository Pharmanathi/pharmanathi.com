// ignore_for_file: prefer_const_constructors

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/bargraph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List monthlystats;
  final List monthlystats2;

  const MyBarGraph(
      {super.key, required this.monthlystats, required this.monthlystats2});

  @override
  Widget build(BuildContext context) {
    final myBardata = BarData(
      junAmount: monthlystats.length > 5 ? monthlystats[5] : 0.0,
      febAmount: monthlystats.length > 1 ? monthlystats[1] : 0.0,
      janAmount: monthlystats.length > 0 ? monthlystats[0] : 0.0,
      aprAmount: monthlystats.length > 3 ? monthlystats[3] : 0.0,
      mayAmount: monthlystats.length > 4 ? monthlystats[4] : 0.0,
      marAmount: monthlystats.length > 2 ? monthlystats[2] : 0.0,
    );

    myBardata.initialisebardata();

    return BarChart(BarChartData(
      borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xff37434d),
              width: 1,
            ),
          )),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
      ),
      titlesData: FlTitlesData(),
      maxY: 100,
      minY: 0,
     barGroups: myBardata.barData.map((data) {
          final y2 =
              myBardata.barData.indexOf(data) < monthlystats2.length ? monthlystats2[myBardata.barData.indexOf(data)] : 0.0;

        Color bar1Color;
        Color bar2Color;

        if (data.y == data.y) {
          bar1Color = Colors.blue;
        } else {
          bar1Color = Colors.blue;
        }

        if (y2 == y2) {
          bar2Color = Colors.grey;
        } else {
          bar2Color = Colors.grey;
        }

        return BarChartGroupData(
          x: data.x,
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              toY: data.y,
              color: bar1Color, // Set the color for the first bar
            ),
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              toY: y2,
              color: bar2Color, // Set the color for the second bar
            ),
          ],
        );
      }).toList(),
    ));
  }
}
