import 'dart:convert';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fos_tracker/charts_views/verification_analysis_region_wise.dart';
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

/// Class for selecting the region whose store data is to be analyzed
class SelectRegion extends StatefulWidget {
  final String title = "Verifications Analysis";

  _SelectRegionState createState() => _SelectRegionState();
}

class _SelectRegionState extends State<SelectRegion> {
  String regionCategory;
  String region;
  int storesVerified = 0;
  int storesRegistered = 0;
  List<StatusSeries> data = [];
  Map<String, dynamic> statusToNumberOfStoresMap = new Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(widget.title, Colors.blue),
      key: _scaffoldKey,
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                "Choose Region",
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Category",
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: regionCategory,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          regionCategory = newValue;
                        });
                      },
                      items: <String>['STATE', 'CITY', 'PINCODE', 'DISTRICT']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(hintText: ("Value")),
                onChanged: (text) {
                  region = text;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                height: 40,
                child: RaisedButton(
                  child: Text("Select"),
                  onPressed: () {
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      duration: new Duration(seconds: 3),
                      content: new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Loading...")
                        ],
                      ),
                    ));
                    getData().whenComplete(() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerificationAnalysis(
                            data: data,
                            regionCategory: regionCategory,
                            region: region,
                            storesRegistered: storesRegistered,
                            storesVerified: storesVerified,
                          ),
                        )));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the count of stores with different verification status i.e. "visited and successful", "visited and failed", "visited and required revisit", "not visited" and adds them in map [statusToNumberOfStoresMap].
  /// This is used ot build data for bar chart.
  /// In data base status red means failed, green means successful and yellow means revisit is required. jsonDecode values for each are used to assign to map.
  Future<String> getData() async {
    final http.Response response = await http.post(
      'https://fos-tracker-278709.an.r.appspot.com/number_of_stores_per_status_by_region',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "regionCategory": regionCategory,
        "regionValue": region,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> jsonDecode = json.decode(response.body);
        statusToNumberOfStoresMap["SUCCESS"] =
            jsonDecode.containsKey("SUCCESS") ? jsonDecode["green"] : 0;
        statusToNumberOfStoresMap["FAIL"] =
            jsonDecode.containsKey("FAIL") ? jsonDecode["red"] : 0;
        statusToNumberOfStoresMap["REVISIT"] =
            jsonDecode.containsKey("REVISIT") ? jsonDecode["yellow"] : 0;
        statusToNumberOfStoresMap["UNVISITED"] =
            jsonDecode.containsKey("UNVISITED") ? jsonDecode["UNVISITED"] : 0;
        storesVerified = statusToNumberOfStoresMap["SUCCESS"] +
            statusToNumberOfStoresMap["FAIL"] +
            statusToNumberOfStoresMap["REVISIT"];
        storesRegistered =
            statusToNumberOfStoresMap["UNVISITED"] + storesVerified;
        print("Http request successful");

        data = setData(
            statusToNumberOfStoresMap["SUCCESS"],
            statusToNumberOfStoresMap["FAIL"],
            statusToNumberOfStoresMap["REVISIT"],
            statusToNumberOfStoresMap["UNVISITED"]);
      });
    } else {
      print("Http request failed");
    }
    return ("Complete");
  }

  /// Sets data for bar chart using map built by [getData] function. Returns list of StatusSeries type data
  List<StatusSeries> setData(
      int success, int fail, int revisit, int unvisited) {
    List<StatusSeries> newData = [
      StatusSeries(
        status: "Successful",
        merchantNumber: statusToNumberOfStoresMap["SUCCESS"],
        color: charts.ColorUtil.fromDartColor(Colors.green),
      ),
      StatusSeries(
        status: "Revisit\nRequired",
        merchantNumber: statusToNumberOfStoresMap["REVISIT"],
        color: ColorUtil.fromDartColor(Colors.yellow),
      ),
      StatusSeries(
        status: "Failed",
        merchantNumber: statusToNumberOfStoresMap["FAIL"],
        color: ColorUtil.fromDartColor(Colors.red),
      ),
      StatusSeries(
        status: "Unvisited",
        merchantNumber: statusToNumberOfStoresMap["UNVISITED"],
        color: charts.ColorUtil.fromDartColor(Colors.blue),
      ),
    ];
    return newData;
  }
}
