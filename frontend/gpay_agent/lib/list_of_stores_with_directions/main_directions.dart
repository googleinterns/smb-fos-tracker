import 'dart:convert';
import 'dart:ffi';
import 'package:agent_app/agent_views/fetch_store.dart';
import 'package:flutter/material.dart';
import 'package:agent_app/list_of_stores_with_directions/store.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent/android_intent.dart';
import 'package:platform/platform.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agent_app/globals.dart' as globals;
import 'package:agent_app/agent_views/merchant_found_notfound.dart';
import 'package:agent_app/business_verification_views/business_verification_view.dart';
import 'package:agent_app/agent_datamodels/store.dart' as GlobalStore;


class MyHomePage extends StatefulWidget {
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions;

  bool loading;

  @override
  void initState() {
    super.initState();
    _buildWidgets();
    getCurrentCoordinates();
    loading = true;
  }

  Future<List<Store>> _populateStores() async {
    List<Store> stores = new List<Store>();

    final response = await http.get(
        "https://fos-tracker-278709.an.r.appspot.com/stores/status");
    if (response.statusCode == 200) {
      LineSplitter lineSplitter = new LineSplitter();
      List<String> lines = lineSplitter.convert(response.body);
      for (var x in lines) {
        if (x != 'Successful') {
          Store store = Store.fromJson(json.decode(x));
          stores.add(store);
        }
      }
      return stores;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Stores List'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Specific Store'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _buildWidgets() {
    _widgetOptions = <Widget>[
      _buildListViewWhenDataIsLoaded(),
      FetchStoreState().buildFetchStore(this.context),
    ];
  }

  void navigateToNextPage(){
    if (globals.isStorePresent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantFound(
            name: globals.store.ownerName.getName(),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantNotFound(),
        ),
      );
    }
  }

  Widget _buildListViewWhenDataIsLoaded() {
    return FutureBuilder(
        future: _populateStores(),
        initialData: [],
        builder: (context, snapshot) {
          return createCountriesListView(context, snapshot);
        }
    );
  }


  Widget createCountriesListView(BuildContext context, AsyncSnapshot snapshot) {
    var values = snapshot.data;
    return ListView.builder(
      itemCount: values == null ? 0 : values.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
//          onTap: () {
//            setState(() {
//              selectedCountry = values[index].code;
//            });
//            print(values[index].code);
//            print(selectedCountry);
//          },
          child: Column(
            children: <Widget>[
               Container(
//                 color: _selectColor(values[index].),
                  child: new ListTile(
                title: Text(values[index].storePhone),
                trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.directions),
                      onPressed: () {
                        String destination = values[index].coordinates.latitude.toString()
                            + "," + values[index].coordinates.longitude.toString();
                        print("destination sent" + destination);
                        _addNavigation(destination);
                      },
                    ), // icon-1
                    FlatButton(
                      onPressed: () async {
                        await GlobalStore.Store.fetchStore(values[index].storePhone);
                        _navigateToVerifyHomePage();
                      },
                      child: Text('VERIFY'),
                    ), // icon-2
                  ],
                ),
//                selected: values[index].code == selectedCountry,
              ),
               ),
              Divider(
                height: 2.0,
              ),
            ],
          ),
        );
      },
    );
  }


  void _navigateToVerifyHomePage(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationView(),
      ),
    );
  }

  void _addNavigation(String destination) {
    print(origin);
    print(origin);
    if (new LocalPlatform().isAndroid) {
      final AndroidIntent intent = new AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(
              "https://www.google.com/maps/dir/?api=1&origin=" +
                  origin + "&destination=" + destination +
                  "&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    }
    else {
      String url = "https://www.google.com/maps/dir/?api=1&origin=" + origin +
          "&destination=" + destination +
          "&travelmode=driving&dir_action=navigate";
//      if (await canLaunch(url)) {
//    await launch(url);
//    } else {
      throw 'Could not launch $url';
//    }
    }
  }

  String origin;

  Future<String> getCurrentCoordinates() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    origin = position.latitude.toString() + "," + position.longitude.toString();
    return origin;
  }
}