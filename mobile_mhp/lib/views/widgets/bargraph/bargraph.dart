import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/views/widgets/bargraph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List monthlystats;
  final List monthlystats2;

  const MyBarGraph(
      {super.key, required this.monthlystats, required this.monthlystats2});

  @override
  Widget build(BuildContext context) {
    final myBardata = BarData(
      junAmount: monthlystats.length > 5 ? monthlystats[5].toDouble() : 0.0,
      febAmount: monthlystats.length > 1 ? monthlystats[1].toDouble() : 0.0,
      janAmount: monthlystats.length > 0 ? monthlystats[0].toDouble() : 0.0,
      aprAmount: monthlystats.length > 3 ? monthlystats[3].toDouble() : 0.0,
      mayAmount: monthlystats.length > 4 ? monthlystats[4].toDouble() : 0.0,
      marAmount: monthlystats.length > 2 ? monthlystats[2].toDouble() : 0.0,
    );

    myBardata.initialisebardata();

    //* List of month labels
    const monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];

    return BarChart(BarChartData(
      groupsSpace: 28.0.w,
      alignment: BarChartAlignment.spaceBetween,
      titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.openSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Pallet.NEUTRAL_300,
                      ),
                    );
                  })),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                //* Adjust index to start from 1
                final index = value.toInt() - 1;
                if (index >= 0 && index < monthLabels.length) {
                  return Text(
                    monthLabels[index],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Pallet.NEUTRAL_300,
                    ),
                  );
                } else {
                  return const Text('');
                }
              },
            ),
          )),
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
      maxY: 100,
      minY: 0,
      barGroups: myBardata.barData.map((data) {
        final y2 = myBardata.barData.indexOf(data) < monthlystats2.length
            ? monthlystats2[myBardata.barData.indexOf(data)].toDouble()
            : 0.0;

        return BarChartGroupData(
          x: data.x,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              toY: data.y.toDouble(),
              color: Pallet.PRIMARY_COLOR, //* Set the color for the first bar
              width: 18.0,
            ),
            BarChartRodData(
              borderRadius: BorderRadius.zero,
              toY: y2,
              color: Pallet.NEUTRAL_200, //* Set the color for the second bar
              width: 18.0,
            ),
          ],
        );
      }).toList(),
    ));
  }
}
