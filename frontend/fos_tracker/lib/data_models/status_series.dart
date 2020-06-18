import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';


// Class to show features of bar in bar chart
class StatusSeries {
  final String status;
  final int merchantNumber;
  final charts.Color color;

  StatusSeries(
      {@required this.status,
        @required this.merchantNumber,
        @required this.color});
}
