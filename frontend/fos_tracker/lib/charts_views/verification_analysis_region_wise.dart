import 'dart:convert';
import 'dart:ui' as UI;
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:fos_tracker/data_models/status_chart.dart';
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart' as painting;
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// Class for creating state of view of verification analysis by region
class RegionalAnalysis extends StatefulWidget {
  final String title = "Verifications Analysis";

  _RegionalAnalysisState createState() => _RegionalAnalysisState();
}

/// Class for building the screen view for regional verification. This includes app bar, analysis chart and scroll up menu for selecting region
class _RegionalAnalysisState extends State<RegionalAnalysis> {
  static const int NUMBER_OF_STATUS_CATEGORIES = 4;

  String regionCategory;
  String regionValue;
  List<charts.Series> seriesList;
  bool _loading = true;
  int numberOfStoresVerified = 0;
  int numberOfStoresRegistered = 0;
  List<StatusSeries> data = [];
  Map<String, dynamic> statusToNumberOfStoresMap = new Map();
  List<String> statusCategories;
  List<String> statusCategoriesInSpanner;
  Map<String, String> colourToStatus;
  String dropDownValue;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    regionCategory = "REGION";
    regionValue = "ALL";
    statusCategories = ["SUCCESS", "FAIL", "REVISIT", "UNVISITED"];
    statusCategoriesInSpanner = ["green", "red", "yellow", "UNVISITED"];
    colourToStatus = {
      "green": "SUCCESS",
      "red": "FAIL",
      "yellow": "REVISIT",
      "UNVISITED": "UNVISITED"
    };
    _loading = true;
    getData();
  }

  /// Gets the count of stores with different verification status i.e. "visited and successful", "visited and failed", "visited and required revisit", "not visited" and adds them in map [statusToNumberOfStoresMap].
  /// This is used to build data for bar chart.
  /// In data base status red means failed, green means successful and yellow means revisit is required. jsonDecode values for each are used to assign to map.
  Future<void> getData() async {
    // Initializing number of stores value for all categories to zero. This acts as default values in case the http request fails or some other error occurs
    for (int i = 0; i < NUMBER_OF_STATUS_CATEGORIES; i++) {
      statusToNumberOfStoresMap[statusCategories[i]] = 0;
    }
    setData();

    final http.Response response = await http.post(
      'https://fos-tracker-278709.an.r.appspot.com/number_of_stores_per_status_by_region',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "regionCategory": regionCategory,
        "regionValue": regionValue,
      }),
    );

    // Checks if the http post request was completed successfully.
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonDecode = json.decode(response.body);
      jsonDecode.forEach((key, value) {
        String status = colourToStatus[key];
        statusToNumberOfStoresMap[status] = value;
      });
      print("Http request successful");
      setData();
    } else {
      print("Http request failed");
    }

    // Sets the loading state to false to assert that the http request has been completed
    setState(() {
      _loading = false;
    });
  }

  /// Sets data for bar chart using map built by [getData] function.
  void setData() {
    List<UI.Color> chartColours = [
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.blue
    ];
    List<String> labels = [
      "Successful",
      "Failed",
      "Revisit\nRequired",
      "Unvisited"
    ];

    // Creating series for the four verification status categories and adding them to the data list that will be used for creating bar chart.
    for (int i = 0; i < NUMBER_OF_STATUS_CATEGORIES; i++) {
      StatusSeries series = new StatusSeries(
        status: labels[i],
        merchantNumber: statusToNumberOfStoresMap[statusCategories[i]],
        color: charts.ColorUtil.fromDartColor(chartColours[i]),
      );
      data.add(series);
    }

    // Calculating the number of stores verified and registered using data from verification status of different categories.
    // A stores is counted as verified if either the verification was successful, failed or required revisit.
    // To calculate all the number of all the stores registered in the selected region, we take sum of stores in every verification category.
    numberOfStoresVerified = statusToNumberOfStoresMap["SUCCESS"] +
        statusToNumberOfStoresMap["FAIL"] +
        statusToNumberOfStoresMap["REVISIT"];
    numberOfStoresRegistered =
        numberOfStoresVerified + statusToNumberOfStoresMap["UNVISITED"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBarTitle: widget.title, appBarColor: Colors.blue),
      body: SlidingUpPanel(
        // Panel shows the details in the expanded view of slide up bar.
        // It contains a form for selecting region whose verification analysis is needed.
        panel: Center(
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
                        value: dropDownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropDownValue = newValue;
                            regionCategory = newValue;
                          });
                        },
                        items: <String>['ALL', 'STATE', 'CITY', 'PINCODE']
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
                Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: (dropDownValue != "ALL"
                                ? "Name of Region Selected"
                                : "Press Select")),
                        validator: (value) {
                          if (value.isEmpty && dropDownValue != "ALL") {
                            return 'Please enter some text';
                          } else {
                            if (dropDownValue == "ALL") {
                              regionCategory = "REGION";
                              regionValue = "ALL";
                            } else {
                              regionCategory = dropDownValue;
                              regionValue = value;
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: RaisedButton(
                          child: Text("Select"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              getData();
                            }
                          },
                        ),
                      )
                    ])),
              ],
            ),
          ),
        ),

        // When collapsed, slide up bar panel shows the selected region.
        collapsed: Container(
          color: Colors.blueGrey,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_up),
                Text(regionCategory + " : " + regionValue),
                Icon(Icons.keyboard_arrow_up)
              ],
            ),
          ),
        ),

        // Body includes the widgets that show on screen when slide panel is collapsed.
        // In includes a bar chart for showing number of merchants in different categories of verification - successful, failed, revisiting required and unvisited.
        body: Center(
          child: ListView(
            children: <Widget>[
              RegisteredVsVerifiedStores(
                registered: numberOfStoresRegistered,
                verified: numberOfStoresVerified,
              ),

              // Container for building bar chart in case http request for building chart is not running.
              // Shows loading symbol when waiting for completion of http response from server to get data for building bar chart.
              Container(
                child: _loading
                    ? Container(
                        height: 400,
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
                    : Chart(
                        data: data,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for creating first row having two cards to display registered stores and verified.
class RegisteredVsVerifiedStores extends StatelessWidget {
  final int registered;
  final int verified;

  RegisteredVsVerifiedStores({this.registered, this.verified});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Text(
                    "STORES REGISTERED",
                  ),
                  Text(
                    registered.toString(),
                    style: painting.TextStyle(
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Text(
                    "STORES VERIFIED",
                  ),
                  Text(
                    verified.toString(),
                    style: painting.TextStyle(
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget for creating bar chart
class Chart extends StatelessWidget {
  final List<StatusSeries> data;

  Chart({this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          height: 550,
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StatusChart(
                  data: data,
                ),
              ),
            ],
          )),
    );
  }
}
