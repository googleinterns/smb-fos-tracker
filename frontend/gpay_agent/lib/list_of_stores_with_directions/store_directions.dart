import 'dart:convert';
import 'dart:ffi';
import 'package:agent_app/agent_views/fetch_store.dart';
import 'package:flutter/material.dart';
import 'package:agent_app/list_of_stores_with_directions/store.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent/android_intent.dart';
import 'package:platform/platform.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agent_app/business_verification_views/business_verification_view.dart';
import 'package:agent_app/agent_datamodels/store.dart' as GlobalStore;
import 'package:url_launcher/url_launcher.dart';

/// VerifyStoresView displays two view, one contains list of stores other has an option to select store by phone.
///
/// This contains a Bottom Navigation bar with two tabs StoresList and SpecificStore.
/// StoresList contains list of all stores that are not verified or requires revisit.
/// SpecificStore contains (fetch_store.dart) Phone and QR which agent can use to select Merchant.
class VerifyStoresView extends StatefulWidget {
  VerifyStoresViewState createState() => VerifyStoresViewState();
}

class VerifyStoresViewState extends State<VerifyStoresView> {
  /// [_selectedIndex] stores the tab we selected.
  int _selectedIndex = 0;
  /// [_widgetOptions] contains List of Widgets that are displayed on tabs.
  List<Widget> _widgetOptions;
  /// origin stores the present location of Agent.
  String origin;

  @override
  void initState() {
    super.initState();
    _buildWidgets();
    getCurrentCoordinates();
  }

  /// Builds Widgets of Bottom Navigation Bar.
  void _buildWidgets() {
    _widgetOptions = <Widget>[
      _buildListViewWhenDataIsLoaded(),
      FetchStoreState().buildFetchStore(this.context),
    ];
  }

  /// Stores the present coordinates of Agent in origin.
  Future<String> getCurrentCoordinates() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    origin = position.latitude.toString() + "," + position.longitude.toString();
    return origin;
  }

  /// Updating the state of [_selectedIndex] when item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Builds the main Scaffold.
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
            icon: Icon(Icons.store),
            title: Text('Stores List'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Specific Store'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  /// Populates the stores list view with the stores whose status is grey or yellow from spanner.
  Future<List<Store>> _populateStores() async {
    List<Store> stores = new List<Store>();

    final response = await http
        .get("https://fos-tracker-278709.an.r.appspot.com/stores/status");
    if (response.statusCode == 200) {
      LineSplitter lineSplitter = new LineSplitter();
      List<String> lines = lineSplitter.convert(response.body);
      for (var x in lines) {
        if (x != 'Successful') {
          Store store = Store.fromJson(json.decode(x));
          if(store.status == "grey" || store.status == "yellow") {
            stores.add(store);
          }
        }
      }
      return stores;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  /// Builds the ListView when data is loaded and shows the waiting image untill it is loaded.
  Widget _buildListViewWhenDataIsLoaded() {
    return FutureBuilder(
        future: _populateStores(),
        initialData: [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty)
            return Image.asset('assets/loading_images/wait.gif');
          else
            return createStoresListView(context, snapshot);
        });
  }

  /// Builds list item for List View.
  ///
  /// List Item has color based on whether Store is unverified or need to revisit.
  /// Each Store has directions, that opens up Google maps app in phone and directs to store location.
  /// Agent can select store to verify directly.
  Widget createStoresListView(BuildContext context, AsyncSnapshot snapshot) {
    var values = snapshot.data;
    return ListView.builder(
      itemCount: values == null ? 0 : values.length,
      itemBuilder: (BuildContext context, int index) {
        print(values[index]);
         return GestureDetector(
          child: Column(
            children: <Widget>[
               Container(
                 padding: EdgeInsets.fromLTRB(2.5, 2.5, 0, 2.5),
                 color: values[index].status == "grey" ? Colors.grey[100]: Colors.yellow[100],
                child: new ListTile(
                  title: Text(
                      values[index].storeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: Text(values[index].storePhone),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      IconButton(
                        icon: Image.asset('assets/loading_images/google_map.png'),
                        onPressed: () {
                          String destination = values[index].coordinates.latitude.toString() +
                              "," +
                              values[index].coordinates.longitude.toString();
                          print("destination sent" + destination);
                          _addNavigation(destination);
                        },
                      ),
                      FlatButton(
                        onPressed: () async {
                          await GlobalStore.Store.fetchStore(
                              values[index].storePhone);
                          _navigateToVerifyHomePage();
                        },
                        child: Text(
                            'VERIFY',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }


  /// Navigates to verification home page.
  void _navigateToVerifyHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationHomeView(),
      ),
    );
  }

  /// Opens up Google maps with present location as origin and store location as destination.
  void _addNavigation(String destination) async {
    print(origin);
    print(origin);
    if (new LocalPlatform().isAndroid) {
      final AndroidIntent intent = new AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(
              "https://www.google.com/maps/dir/?api=1&origin=" +
                  origin +
                  "&destination=" +
                  destination +
                  "&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    } else {
      String url = "https://www.google.com/maps/dir/?api=1&origin=" +
          origin +
          "&destination=" +
          destination +
          "&travelmode=driving&dir_action=navigate";
        if (await canLaunch(url)) {
          await launch(url);
        } else {
      throw 'Could not launch $url';
    }
    }
  }
}
