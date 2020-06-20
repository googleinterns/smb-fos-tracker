import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fos_tracker/data_models/stores_with_time.dart';

class TimeAnalysis extends StatefulWidget {
  final List<charts.Series> seriesList;
  final String title = "Verifications Analysis";

  TimeAnalysis({this.seriesList});

  _TimeAnalysisState createState() => _TimeAnalysisState();
}

class _TimeAnalysisState extends State<TimeAnalysis> {
  @override
  Widget build(BuildContext context) {
    print(widget.seriesList);
    return Scaffold(
        appBar: CustomAppBar(widget.title, Colors.blue),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'WEEK WISE ANALYSIS',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style:
                  painting.TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text("REGISTERED"),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Text("SUCCESSFUL"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Center(
                      child: Text("FAILED"),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow,
                    child: Center(
                      child: Text("NEED REVISIT"),
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: 600,
              padding: EdgeInsets.all(20),
              child: new charts.BarChart(
                widget.seriesList,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                vertical: false,
                animationDuration: Duration(seconds: 2),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(child: Center(child: Text("NUMBER OF MERCHANTS"))),
              ],
            ),
          ],
        ));
  }
}
