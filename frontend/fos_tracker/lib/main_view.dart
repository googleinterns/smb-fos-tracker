import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
  This class contains the UI for the main map view that is generated on app launch.
 */
class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Completer<GoogleMapController> controller;
  bool agentView = true;
  bool httpDone = true;

  void initState() {
    _getUserLocation();
    getAgentLocations();
    getMerchantLocations();
    super.initState();
  }

  void _getUserLocation() async {}

  _onMapCreated(GoogleMapController controllerArg) async {
    setState(() {
      controller.complete(controllerArg);
    });
  }

  void getAgentLocations() async {}

  void getMerchantLocations() async {}

  void updateMarker() async {}

  @override
  Widget build(BuildContext context) {
    const oneSec = const Duration(milliseconds: 500);
    new Timer.periodic(oneSec, (Timer t) => httpDone ? updateMarker() : null);
    return Scaffold();
  }
}
