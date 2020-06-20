import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'globals.dart' as globals;

/*
  This class contains the UI for the view that is generated on clicking on an agent in the main map.
 */
class AgentPage extends StatefulWidget {
  final String agentEmail;

  AgentPage({Key key, @required this.agentEmail}) : super(key: key);

  @override
  _AgentPageState createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  //TODO: fetch agent verifications
  Completer<GoogleMapController> controller = Completer();
  String agentFirstName;
  String agentName;
  String agentPhone;
  String agentCreationTime;

  _onMapCreated(GoogleMapController controllerArg) async {
    setState(() {
      controller.complete(controllerArg);
    });
  }

  @override
  void initState() {
    getAgentInfo();
    super.initState();
  }

  Future<void> getAgentInfo() async {
    var result = await http.post(
        "https://fos-tracker-278709.an.r.appspot.com/agent/email",
        body: jsonEncode(<String, String>{"agentEmail": widget.agentEmail}));
    if (result.statusCode != 200) {
      setState(() {});
    } else {
      try {
        LineSplitter lineSplitter = new LineSplitter();
        List<String> lines = lineSplitter.convert(result.body);
        String json = lines[0];
        var jsonDecoded = jsonDecode(json);
        setState(() {
          agentFirstName = jsonDecoded['name']['firstName'];
          agentName = jsonDecoded['name']['firstName'] +
              ' ' +
              jsonDecoded['name']['middleName'] +
              ' ' +
              jsonDecoded['name']['lastName'];
          agentPhone = jsonDecoded['phone'];
          agentCreationTime = jsonDecoded['agentCreationDateTime'];
        });
      } catch (e) {
        print(e + "error parsing agent info");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.agentEmail),
      ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        panel: Center(
          child: agentFirstName == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Name: " + agentName),
                    Text("Phone: " + agentPhone),
                    Text("Email: " + widget.agentEmail),
                    Text("Time of creation: " + agentCreationTime)
                  ],
                ),
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: globals.currentPosition,
            zoom: 12,
          ),
          onMapCreated: _onMapCreated,
          zoomGesturesEnabled: true,
          myLocationEnabled: true,
          compassEnabled: true,
          onCameraMove: (position) {},
          markers: globals.verifiedMerchantMarkers,
        ),
        collapsed: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.keyboard_arrow_up),
              (agentFirstName == null || agentFirstName.isEmpty)
                  ? Text(" Swipe up to view agent info")
                  : Text(" Swipe up to view " + agentFirstName + "'s info"),
              Icon(Icons.keyboard_arrow_up)
            ],
          ),
        ),
        minHeight: MediaQuery.of(context).size.height * 0.06,
      ),
    );
  }
}
