import 'dart:convert';
import 'dart:typed_data';
import 'package:agent_app/agent_datamodels/store.dart';
import 'package:agent_app/agent_views/merchant_found_notfound.dart';
import 'package:agent_app/custom_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:agent_app/globals.dart' as globals;
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;

class FetchStore extends StatefulWidget {
  FetchStoreState createState() => FetchStoreState();
}

/// Builds the UI elements for fetching store information for verification.
/// Store can be fetched using phone number or scanner QR code assigned to store.
class FetchStoreState extends State<FetchStore> {
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String num = "1223";
  Uint8List bytes = Uint8List(200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: CustomAppBar("", Colors.white),
      body: OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return _buildFetchStorePortraitView();
        } else {
          return _buildFetchStoreLandScapeView();
        }
      }),
    );
  }

  /// Builds portrait view.
  Widget _buildFetchStorePortraitView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          _buildPhoneChild(),
          SizedBox(
            height: 20,
          ),
          _buildQRChild()
        ],
      ),
    );
  }

  /// Builds landscape view.
  Widget _buildFetchStoreLandScapeView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          _buildPhoneChild(),
          SizedBox(
            width: 20,
          ),
          _buildQRChild()
        ],
      ),
    );
  }

  /// Fetches store details using phone number of store.
  /// If store number is registered in database, it calls [MerchantFound]
  /// interface otherwise it calls [MerchantNotFound] interface.
  Widget _buildPhoneChild() {
    return Expanded(
      flex: 1,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Phone Number",
//                    textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Enter the phone number with which the merchant registered the store.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        num = (number.phoneNumber).toString();
                      },
                      initialValue: number,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ButtonTheme(
                      minWidth: 200,
                      height: 50,
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: new Text("Submit"),
                        onPressed: () async {
                          await Store.fetchStore(num.substring(3));
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
                        },
                      ),
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  Widget _buildQRChild() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Scan QR code",
//                  textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "QR Code is generated when the merchant registers the store using merchant app",
                      style: TextStyle(
//                        fontSize: 17,
                          ),
                    ),
                  )),
              /*SizedBox(
                child: Image.memory(bytes),
              ),*/
              Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Center(
                      child: ButtonTheme(
                        minWidth: 200,
                        height: 50,
                        child: FlatButton(
                          onPressed: _scan,
                          textColor: Colors.white,
                          color: Colors.blue,
                          child: new Text("Scan QR Code"),
                        ),
                      ),
                    ),
                  ))
            ]),
      ),
    );
  }

  /// Fetches text of QR code by calling scan() API of qr_scan plugin.
  /// Navigate to [MerchantFound] interface if [qrcode] is registered with any store,
  /// else navigate to [MerchantNotFound] interface.
  Future _scan() async {
    String qrcode = await scanner.scan();
    //Use QR code to get store, if store is registered, pass merchant name found, else not found
    Navigator.pop(context);
    if (qrcode == "73") {
      //73 is a hard coded as a valid store QR code currently
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantFound(name: "Alice Peterson"),
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

  /// Fetches store from the spanner database.
  Future<Null> fetchStore(String phone) async {
    print('started' + phone);
    var response = await http.post(
        "https://fos-tracker-278709.an.r.appspot.com/store/phone",
        body: jsonEncode(<String, String>{"storePhone": phone}));
    if (response.statusCode == 200) {
      print('found number');
      try {
        LineSplitter lineSplitter = new LineSplitter();
        List<String> lines = lineSplitter.convert(response.body);
        String jsonString = lines[0];
        print(jsonString);
        globals.isStorePresent = true;
        print(json.decode(jsonString));
        globals.store = Store.fromJson(jsonDecode(jsonString));
        print('returned data');
      } catch (e) {
        print("error");
      }
    } else {
      print('number not found');
      globals.isStorePresent = false;
    }
  }
}
