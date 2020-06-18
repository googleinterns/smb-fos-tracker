import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fos_tracker/custom_widgets/app_bar.dart';
import 'package:fos_tracker/data_models/status_chart.dart';
import 'package:fos_tracker/data_models/status_series.dart';
import 'package:fos_tracker/globals.dart' as globals;

/// Creates the state of bar graph view. It accepts data from [select_region.dart] and assigns it to widget variables.
class VerificationAnalysis extends StatefulWidget {
  final String title = "Verifications Analysis";
  final List<StatusSeries> data;
  final String regionCategory;
  final String region;
  final int storesVerified;
  final int storesRegistered;

  VerificationAnalysis(
      {@required this.data,
      @required this.regionCategory,
      @required this.region,
      @required this.storesVerified,
      @required this.storesRegistered});

  _VerificationAnalysisState createState() => _VerificationAnalysisState();
}

/// Class for defining state of bar graph
class _VerificationAnalysisState extends State<VerificationAnalysis> {
  @override
  Widget build(BuildContext context) {
    print(globals.statusToNumberOfStoresMap);
    return Scaffold(
      appBar: CustomAppBar(widget.title, Colors.blue),
      //Set to true for bottom appbar overlap body content
      extendBody: true,
      body: Center(
        child: ListView(
          children: <Widget>[
            RegisteredVsVerifiedStores(
              registered: widget.storesRegistered,
              verified: widget.storesVerified,
            ),
            Chart(
              data: widget.data,
            ),
            RegionDetailsWidget(
              regionCategory: widget.regionCategory,
              regionValue: widget.region,
            ),
            Container(
              width: 200,
              height: 60,
              child: RaisedButton(
                color: Colors.blue,
                child: Text(
                  "CHANGE FILTER",
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
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
                    style: TextStyle(
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
                    style: TextStyle(
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

/// Widget for creating bottom row that shows the region selected.
class RegionDetailsWidget extends StatelessWidget {
  final String regionCategory;
  final String regionValue;

  RegionDetailsWidget({this.regionCategory, this.regionValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            child: Center(
              child: Text(
                regionCategory,
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: Card(
          child: Center(
            child: Text(
              regionValue,
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ))
      ],
    );
  }
}

/// Widget for creating bar chart
class Chart extends StatelessWidget {
  List<StatusSeries> data;

  Chart({this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          height: 500,
          padding: EdgeInsets.all(20),
          child: Expanded(
            child: StatusChart(
              data: data,
            ),
          )),
    );
  }
}
