import 'package:pharma_nathi/views/widgets/bargraph/indivitual_bar.dart';

class BarData {
  final double janAmount;

  final double febAmount;

  final double marAmount;

  final double aprAmount;

  final double mayAmount;

  final double junAmount;


  BarData(
      {required this.junAmount,

      required this.febAmount,

      required this.janAmount,

      required this.mayAmount,

      required this.marAmount,

      required this.aprAmount,
      });

  List<IndivitualBar> barData = [];

  void initialisebardata() {
    barData = [
      IndivitualBar(x: 1, y: janAmount),

      IndivitualBar(x: 2, y: febAmount),

      IndivitualBar(x: 3, y: marAmount),

      IndivitualBar(x: 4, y: aprAmount),

      IndivitualBar(x: 5, y: mayAmount),

      IndivitualBar(x: 6, y: junAmount),

    ];
  }

  String getMonthName(int monthNumber) {
  switch (monthNumber) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    default:
      return '';
  }
}
}
