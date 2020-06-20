import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fos_tracker/charts_views/verification_analysis_time_wise.dart';
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:fos_tracker/data_models/stores_with_time.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

/// Class for selecting the region whose store data is to be analyzed
class SelectTime extends StatefulWidget {
  final String title = "Verifications Analysis";

  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
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

  @override
  void initState() {
    seriesList = new List();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(widget.title, Colors.blue),
      body: ListView(
        children: <Widget>[
          RaisedButton(
            child: Text("Current Week"),
            onPressed: (){
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                duration: new Duration(seconds: 6),
                content: new Row(
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new Text("  Loading...")
                  ],
                ),
              ));
              getData().whenComplete(() =>
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeAnalysis(
                        seriesList: seriesList,
                      ),
                    ))
              );
            },
          ),
          Text(
            (errorMessage == null)? "":errorMessage,
          )
        ],
      ),
    );
  }

  /// Gets the count of stores with different verification status i.e. "visited and successful", "visited and failed", "visited and required revisit", "not visited" and adds them in map [statusToNumberOfStoresMap].
  /// This is used ot build data for line chart.
  /// In data base status red means failed, green means successful and yellow means revisit is required. jsonDecode values for each are used to assign to map.
  Future<String> getData() async {
    const int NUMBER_OF_CATEGORIES = 4;
    const int NUMBER_OF_DAYS_IN_WEEK = 7;
    DateTime today = DateTime.now();
    int day = today.weekday;
    DateTime startDay = today.subtract(new Duration(days: (day-1)));
    DateTime endDay = startDay.add(new Duration(days: 6));
    String startDate = startDay.toString().split(" ")[0];
    String endDate = endDay.toString().split(" ")[0];

    List<String> categories = ["registered", "successful","failed", "revisit"];
    List<Color> chartColours = [Colors.blue, Colors.green, Colors.red, Colors.yellow];

    Map<String, Map<String, int>> chartData = new Map();

    // Initializing map for all dates in the current week
    for(int i = 0; i < NUMBER_OF_CATEGORIES; i ++){
      chartData[categories[i]] = new Map();
    }
    for(int i = 0; i < NUMBER_OF_DAYS_IN_WEEK; i ++){
      DateTime dateIterator = startDay.add(new Duration(days: i));
      String date = dateIterator.toString().split(" ")[0];
      for(int j = 0; j < NUMBER_OF_CATEGORIES; j ++){
        chartData[categories[j]][date] = 0;
        print(categories[j]);
        print(date);
        print(chartData[categories[j]][date]);
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

    if (response.statusCode == 200) {
      seriesList = new List();
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      print(decodedResponse);

      decodedResponse.forEach((category, list) {
        decodedResponse[category].forEach((date, numberOfMerchants) {
          chartData[category][date] = numberOfMerchants;
          print(category);
          print(date);
          print(chartData[category][date]);
        });
        print("printing still!");
      });
      print("Running !");
      for(int i = 0; i < NUMBER_OF_CATEGORIES; i ++) {
        print("Running inside loop also!");
        String category = categories[i];
        print(category);
        List<StoresWithDate> lineData = [];
        for(int j = 0; j < NUMBER_OF_DAYS_IN_WEEK; j ++) {
          DateTime dateIterator = startDay.add(new Duration(days: j));
          String date = dateIterator.toString().split(" ")[0];
          print(category);
          print(date);
          print(chartData[category][date]);
          lineData.add(new StoresWithDate(date: date, numberOfStores: chartData[category][date]));
        }

        seriesList.add(new charts.Series<StoresWithDate, String>(
            id: category,
            seriesColor: charts.ColorUtil.fromDartColor(chartColours[i]),
            data: lineData,
            domainFn: (StoresWithDate numberOfStores, _) => numberOfStores.date,
            measureFn: (StoresWithDate numberOfStores, _) => numberOfStores.numberOfStores),
        );
      }
    } else {
      print("Http request failed");
    }
    return ("Complete");
  }
}
