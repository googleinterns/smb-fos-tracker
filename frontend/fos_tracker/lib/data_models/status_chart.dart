import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:charts_flutter/flutter.dart' as charts;


/// Class that defines features of the complete chart i.e. domain and measure of bar
class StatusChart extends StatelessWidget {
  final List<StatusSeries> data;

  StatusChart({
    @required this.data,
  });

  @override
  Widget build(BuildContext context) {
    List<charts.Series<StatusSeries, String>> series = [
      charts.Series(
        id: "Number of Merchants",
        data: data,
        domainFn: (StatusSeries series, _) => series.status,
        measureFn: (StatusSeries series, _) => series.merchantNumber,
        colorFn: (StatusSeries series, _) => series.color,
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
    );
  }
}
