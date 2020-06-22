import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fos_tracker/agent_info_page.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'agent.dart';
import 'globals.dart' as globals;
import 'merchant_info_page.dart';
import 'store.dart';

/*
  This class contains the UI for the main map view that is generated on app launch.
 */
class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Completer<GoogleMapController> controller = Completer();
  bool agentView = true;
  bool httpDone = true;

  void initState() {
    _getUserLocation();
    getAgentLocations();
    getMerchantLocations();
    super.initState();
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      globals.startPosition = LatLng(position.latitude, position.longitude);
    });
  }

  _onMapCreated(GoogleMapController controllerArg) async {
    setState(() {
      controller.complete(controllerArg);
    });
  }

  void getAgentLocations() async {
    var result =
    await http.get("https://fos-tracker-278709.an.r.appspot.com/agents");

    if (result.statusCode == 200) {
      LineSplitter lineSplitter = new LineSplitter();
      List<String> lines = lineSplitter.convert(result.body);
      for (var x in lines) {
        if (x != 'Successful') {
          Agent agent = Agent.fromJson(jsonDecode(x));
          setState(() {
            globals.agentMarkers.add(
              Marker(
                  markerId: MarkerId(agent.email),
                  position: LatLng(
                      agent.coordinates.latitude, agent.coordinates.longitude),
                  onTap: () async {
                    globals.verifiedMerchantMarkers.clear();
                    globals.currentPosition = LatLng(agent.coordinates.latitude,
                        agent.coordinates.longitude);
                    var result = await http.post(
                        "https://fos-tracker-278709.an.r.appspot.com/agent/stores/status/",
                        body: jsonEncode(
                            <String, String>{"agentEmail": agent.email}));
                    print(agent.email);
                    print(result.statusCode);
                    if (result.statusCode == 200) {
                      LineSplitter lineSplitter = new LineSplitter();
                      List<String> lines = lineSplitter.convert(result.body);
                      for (var x in lines) {
                        if (x != 'Successful') {
                          Store store = Store.fromJson(jsonDecode(x));
                          setState(() {
                            globals.verifiedMerchantMarkers.add(
                              Marker(
                                  markerId: MarkerId(store.storePhone),
                                  position: LatLng(store.coordinates.latitude,
                                      store.coordinates.longitude),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MerchantPage(
                                                  storePhone: store.storePhone,
                                                )));
                                  },
                                  icon: store.status == 'grey'
                                      ? BitmapDescriptor.fromAsset('images/m_grey.png')
                                      : (store.status == 'green'
                                      ? BitmapDescriptor.fromAsset('images/m_green.png')
                                      : (store.status == 'yellow' ? BitmapDescriptor.fromAsset(
                                      'images/m_yellow.png') : BitmapDescriptor.fromAsset(
                                      'images/m_red.png')))
                              ),
                            );
                          });
                        }
                      }
                    }
                    print(globals.verifiedMerchantMarkers.length);
                    print("^^^^^^^^^");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AgentPage(
                                  agentEmail: agent.email,
                                )));
                  },
                  icon: BitmapDescriptor.fromAsset("images/a.png")),
            );
          });
        }
      }
    }
  }

  void getMerchantLocations() async {
    var result = await http
        .get("https://fos-tracker-278709.an.r.appspot.com/stores/status");
    if (result.statusCode == 200) {
      LineSplitter lineSplitter = new LineSplitter();
      List<String> lines = lineSplitter.convert(result.body);
      globals.merchantMarkers.clear();
      for (var x in lines) {
        if (x != 'Successful') {
          Store store = Store.fromJson(jsonDecode(x));
          setState(() {
            globals.merchantMarkers.add(
              Marker(
                  markerId: MarkerId(store.storePhone),
                  position: LatLng(
                      store.coordinates.latitude, store.coordinates.longitude),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MerchantPage(
                                  storePhone: store.storePhone,
                                )));
                  },
                  icon: store.status == 'grey'
                      ? BitmapDescriptor.fromAsset('images/m_grey.png')
                      : (store.status == 'green'
                      ? BitmapDescriptor.fromAsset('images/m_green.png')
                      : (store.status == 'yellow' ? BitmapDescriptor.fromAsset(
                      'images/m_yellow.png') : BitmapDescriptor.fromAsset(
                      'images/m_red.png')))
              ),
            );
          });
        }
      }
    }
  }

  void updateMarker() async {
    setState(() {
      httpDone = false;
    });
    List<Agent> newAgents = [];
    var result =
    await http.get("https://fos-tracker-278709.an.r.appspot.com/agents");
    if (result.statusCode == 200) {
      LineSplitter lineSplitter = new LineSplitter();
      List<String> lines = lineSplitter.convert(result.body);
      for (var x in lines) {
        if (x != 'Successful') {
          Agent agent = Agent.fromJson(jsonDecode(x));
          newAgents.add(agent);
        }
      }
    }

    for (var x in newAgents) {
      setState(() {
        globals.agentMarkers.removeWhere((m) => m.markerId.value == x.email);
        globals.agentMarkers.add(Marker(
            markerId: MarkerId(x.email),
            position: LatLng(x.coordinates.latitude, x.coordinates.longitude),
            onTap: () async {
              globals.verifiedMerchantMarkers.clear();
              globals.currentPosition =
                  LatLng(x.coordinates.latitude, x.coordinates.longitude);
              var result = await http.post(
                  "https://fos-tracker-278709.an.r.appspot.com/agent/stores/status/",
                  body: jsonEncode(<String, String>{"agentEmail": x.email}));
              print(x.email);
              print(result.statusCode);
              if (result.statusCode == 200) {
                LineSplitter lineSplitter = new LineSplitter();
                List<String> lines = lineSplitter.convert(result.body);
                for (var x in lines) {
                  if (x != 'Successful') {
                    Store store = Store.fromJson(jsonDecode(x));
                    setState(() {
                      globals.verifiedMerchantMarkers.add(
                        Marker(
                            markerId: MarkerId(store.storePhone),
                            position: LatLng(store.coordinates.latitude,
                                store.coordinates.longitude),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MerchantPage(
                                            storePhone: store.storePhone,
                                          )));
                            },
                            icon: store.status == 'grey'
                                ? BitmapDescriptor.fromAsset(
                                'images/m_grey.png')
                                : (store.status == 'green'
                                ? BitmapDescriptor.fromAsset(
                                'images/m_green.png')
                                : BitmapDescriptor.fromAsset(
                                'images/m_red.png'))
//                              )
                        ),
                      );
                    });
                  }
                }
              }
              print(globals.verifiedMerchantMarkers.length);
              print("^^^^^^^^^");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AgentPage(
                            agentEmail: x.email,
                          )));
            },
            icon: BitmapDescriptor.fromAsset("images/a.png")));
      });
    }
    setState(() {
      httpDone = true;
    });
  }

  Future<void> updateLocation(
      Completer<GoogleMapController> controllerArg) async {
    final GoogleMapController controller = await controllerArg.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: globals.startPosition)));
  }

  @override
  Widget build(BuildContext context) {
    showPincodeDialog() {
      TextEditingController pincodeController = new TextEditingController();
      Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          globals.pincode = pincodeController.text;
          try {
            int pincode = int.parse(globals.pincode);
            if (pincode >= 100000 && pincode <= 999999) {
              GoogleMapController contr = await controller.future;
              final query = pincode.toString();
              var addresses =
              await Geocoder.local.findAddressesFromQuery(query);
              var first = addresses.first;
              setState(() {
                contr.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(first.coordinates.latitude,
                            first.coordinates.longitude),
                        zoom: 14)));
              });
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
              globals.showAlertDialog("Error", "Invalid pincode", context);
            }
          } catch (e) {
            Navigator.of(context).pop();
            globals.showAlertDialog("Error", "Could not find pincode", context);
          }
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text("Input Pincode"),
        content: TextField(
          controller: pincodeController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    // This is where the constant update of agents location happens.
    const oneSec = const Duration(milliseconds: 500);
    new Timer.periodic(oneSec, (Timer t) => httpDone ? updateMarker() : null);
    return Scaffold(
        appBar: AppBar(
          title: agentView ? Text("Agents") : Text("Merchants"),
          actions: <Widget>[
            agentView
                ? SizedBox()
                : IconButton(
              icon: Icon(Icons.refresh),
              onPressed: getMerchantLocations,
            ),
            agentView
                ? SizedBox()
                : FlatButton(
              child: Row(
                children: <Widget>[
                  Text(
                    "Pincode ",
                    softWrap: true,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 12,
                  )
                ],
              ),
              onPressed: () async {
                showPincodeDialog();
              },
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.05,
              ),
              ListTile(
                title: Text("Agent View"),
                onTap: () {
                  setState(() {
                    agentView = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Merchant View"),
                onTap: () {
                  setState(() {
                    agentView = false;
                  });
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        body: (globals.startPosition == null)
            ? Center(child: CircularProgressIndicator())
            : GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: globals.startPosition,
            zoom: 14.4746,
          ),
          onMapCreated: _onMapCreated,
          zoomGesturesEnabled: true,
          myLocationEnabled: true,
          compassEnabled: true,
          markers:
          agentView ? globals.agentMarkers : globals.merchantMarkers,
        ),
        bottomNavigationBar: !agentView ?
    BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
            Icon(Icons.brightness_1, color: Colors.grey,),
              Text("Incomplete"),
            ]
          ),
          Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Icon(Icons.brightness_1, color: Colors.yellow,),
                Text("Revisit needed"),
              ]
          ),
          Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Icon(Icons.brightness_1, color: Colors.red,),
                Text("Failed"),
              ]
          ),
          Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Icon(Icons.brightness_1, color: Colors.green,),
                Text("Successful"),
              ]
          )
        ],
      ),
    )
            : null);
  }
}
