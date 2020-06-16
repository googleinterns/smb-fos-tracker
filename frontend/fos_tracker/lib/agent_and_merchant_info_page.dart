import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  Completer<GoogleMapController> controller;
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

  Future<void> getAgentInfo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

/*
  This class contains the UI for the view that is generated on clicking on a merchant in the main map or from an agent map.
 */
class MerchantPage extends StatefulWidget {
  final String storePhone;

  MerchantPage({Key key, @required this.storePhone}) : super(key: key);

  @override
  _MerchantPageState createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  String storeName;
  String ownerName;
  String email;
  String storeCreationTime;
  String address;

  @override
  void initState() {
    getMerchantInfo();
    super.initState();
  }

  Future<void> getMerchantInfo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
