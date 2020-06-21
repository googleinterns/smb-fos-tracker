import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:fos_tracker/data_models/stores_with_time.dart';
import 'package:http/http.dart' as http;

/// Class for creating state of view of verification analysis by week.
class TimeAnalysis extends StatefulWidget {
  final String title = "Verifications Analysis";

  _TimeAnalysisState createState() => _TimeAnalysisState();
}

/// Class for building the screen view for time wise verification. This includes app bar, analysis chart and calendar button for selecting a day of the week.
class _TimeAnalysisState extends State<TimeAnalysis> {
  static const int NUMBER_OF_CATEGORIES = 4;
  static const int NUMBER_OF_DAYS_IN_WEEK = 7;

  DateTime pickedDate;
  bool _loading = true;
  List<charts.Series<StoresWithDate, String>> seriesList;
  String startTime;
  String endTime;
  String regionCategory;
  String region;
  String errorMessage;
  int storesVerified = 0;
  int storesRegistered = 0;
  List<StatusSeries> data = [];
  Map<String, dynamic> statusToNumberOfStoresMap = new Map();

  /// Initializes the picked date to present date so that when the application page opens for the first time, details of the current week are shown on screen.
  /// Sets [_loading] to true so that while the http request is being made, circular progress indicator is visible on screen.
  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    _loading = true;
    getData();
  }

  /// Gets the count of stores with different verification status i.e. "visited and successful", "visited and failed", "visited and required revisit", "not visited" and adds them in map [statusToNumberOfStoresMap].
  /// This is used to build the data for week wise bar chart.
  /// In data base status red means failed, green means successful and yellow means revisit is required. jsonDecode values for each are used to assign to map.
  Future<void> getData() async {
    DateTime selectedDate = pickedDate;
    int day = selectedDate.weekday;
    DateTime startDay = selectedDate.subtract(new Duration(days: (day - 1)));
    DateTime endDay = startDay.add(new Duration(days: 6));
    String startDate = startDay.toString().split(" ")[0];
    String endDate = endDay.toString().split(" ")[0];

    List<String> categories = ["registered", "successful", "failed", "revisit"];
    List<Color> chartColours = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow
    ];

    Map<String, Map<String, int>> chartData = new Map();

    // Initializing map for all dates in the current week. Setting all values to 0.
    for (int i = 0; i < NUMBER_OF_CATEGORIES; i++) {
      chartData[categories[i]] = new Map();
    }
    for (int i = 0; i < NUMBER_OF_DAYS_IN_WEEK; i++) {
      DateTime dateIterator = startDay.add(new Duration(days: i));
      String date = dateIterator.toString().split(" ")[0];
      for (int j = 0; j < NUMBER_OF_CATEGORIES; j++) {
        chartData[categories[j]][date] = 0;
      }
    }

    final http.Response response = await http.post(
      'https://fos-tracker-278709.an.r.appspot.com/number_of_stores_per_status_by_time',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "startTime": startDate,
        "endTime": endDate,
      }),
    );

    // If the http request is successful, [chartDate] is modified with the values obtained from http post request.
    if (response.statusCode == 200) {
      seriesList = new List();
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      decodedResponse.forEach((category, list) {
        decodedResponse[category].forEach((date, numberOfMerchants) {
          chartData[category][date] = numberOfMerchants;
        });
      });
      for (int i = 0; i < NUMBER_OF_CATEGORIES; i++) {
        String category = categories[i];
        List<StoresWithDate> lineData = [];
        for (int j = 0; j < NUMBER_OF_DAYS_IN_WEEK; j++) {
          DateTime dateIterator = startDay.add(new Duration(days: j));
          String date = dateIterator.toString().split(" ")[0];

          lineData.add(new StoresWithDate(
              date: date, numberOfStores: chartData[category][date]));
        }

        seriesList.add(
          new charts.Series<StoresWithDate, String>(
              id: category,
              seriesColor: charts.ColorUtil.fromDartColor(chartColours[i]),
              data: lineData,
              domainFn: (StoresWithDate numberOfStores, _) =>
                  numberOfStores.date,
              measureFn: (StoresWithDate numberOfStores, _) =>
                  numberOfStores.numberOfStores),
        );
      }
    } else {
      print("Http request failed");
    }

    // Sets the state as non loading when http request completes. This is done to refresh the view to show bar chart in place of circular progress indicator.
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(seriesList);
    return Scaffold(
        appBar:
            CustomAppBar(appBarTitle: widget.title, appBarColor: Colors.blue),
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
            // It checks if the current state is loading state. _loading is true only when the http request is running in asynchronously.
            // If _loading is true, circular progress indicator appears on screen. Once loading is complete and new state is set, bar chart appears on screen.
            Container(
              height: 600,
              padding: EdgeInsets.all(20),
              child: _loading
                  ? Container(
                      child: new Center(
                        child: new SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 7.0,
                          ),
                        ),
                      ),
                    )
                  : new charts.BarChart(
                      seriesList,
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
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Choose date to change the selected week -> ",
                    ),
                  ),
                  FloatingActionButton(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.date_range,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: DateTime(2010),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          pickedDate = value;
                        });
                        setState(() {
                          _loading = true;
                        });
                        getData();
                      })
                ],
              ),
            )
          ],
        ));
  }
}
