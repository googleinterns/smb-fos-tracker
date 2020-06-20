import 'dart:async';
import 'dart:convert';
import 'package:agent_app/custom_widgets/app_bar.dart';
import 'package:agent_app/custom_widgets/personal_details_textbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:agent_app/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:agent_app/list_of_stores_with_directions/store_directions.dart';

class WelcomeAgent extends StatefulWidget {
  _WelcomeAgentState createState() => _WelcomeAgentState();
}

/// Builds the UI elements for Welcome Agent user interface and
/// starts [positionSubscription] stream for continuously fetching agent location
/// and make request to server for updating location in spanner.
class _WelcomeAgentState extends State<WelcomeAgent> {
  static const int UPDATE_DISTANCE = 1;
  Geolocator _geolocator;
  Position _position;
  StreamSubscription<Position> positionSubscription;

  /// Checks the status of GPS granted by user
  /// locationAlways means GPS location will be traced when app is running either in background or foreground.
  /// locationWhenInUse means GPS location will be traced when this application is the running app.
  /// Default status will be granted if either of the two is granted
  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    _geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  /// Initializes _goelocator and stream for listening changes in device location.
  /// Position will be changed if distance changes by [UPDATE_DISTANCE]
  @override
  initState() {
    super.initState();

    _geolocator = Geolocator();
    LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.high, distanceFilter: UPDATE_DISTANCE);

    checkPermission();

    positionSubscription = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      print("Starting to Listen!");
      _position = position;
      double latitude = (_position != null ? _position.latitude : 0);
      double longitude = (_position != null ? _position.longitude : 0);
      print(latitude);
      print(longitude);
      if (globals.googleSignIn.currentUser.email != null) {
        await updateAgentLocation(latitude, longitude);
      } else {
        dispose();
      }
    });
  }

  @override
  void dispose() {
    positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar("Welcome " + globals.agent.AgentName.firstName, Colors.white),
      body: ListView(padding: const EdgeInsets.all(8.0), children: <Widget>[
        Image.asset(
          "assets/agent_beginning_images/using_gpay.png",
          height: 160,
        ),
        Center(
          child: Text(
            "AGENT PROFILE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        PersonalDetailsTextBox(
          title: "Name",
          value: globals.agent.getName(),
          icon: Icon(Icons.face),
        ),
        SizedBox(
          height: 10,
        ),
        PersonalDetailsTextBox(
          title: "Phone Number",
          value: globals.agent.AgentPhone,
          icon: Icon(Icons.phone),
        ),
        SizedBox(
          height: 10,
        ),
        PersonalDetailsTextBox(
          title: "Joining Date",
          value: globals.agent.AgentCreationDateTime,
          icon: Icon(Icons.calendar_today),
        ),
        SizedBox(
          height: 10,
        ),
        PersonalDetailsTextBox(
          title: "Number of merchants verified",
          value: (globals.merchantsVerifiedbyAgent).toString(),
          icon: Icon(Icons.star),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ButtonTheme(
            minWidth: 200,
            height: 50,
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerifyStoresView()),
                );
              },
              textColor: Colors.white,
              color: Colors.blue,
              padding: const EdgeInsets.all(8.0),
              child: new Text(
                "Verify a Store",
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// Creates a json encoding with user email and present latitude and longitude
  /// of his/her position and makes a post request to update in spanner. Prints
  /// status of update in console
  Future<int> updateAgentLocation(double latitude, double longitude) async {
    final http.Response response = await http.post(
      'https://fos-tracker-278709.an.r.appspot.com/update_agent_location',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": globals.googleSignIn.currentUser.email,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );
    if (response.statusCode == 200) {
      print("Location Updated successfully :) ");
    } else {
      print("Location updating failed");
    }
  }
}
