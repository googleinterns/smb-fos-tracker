import 'dart:typed_data';
import 'package:agent_app/agent_datamodels/store.dart';
import 'package:agent_app/agent_views/merchant_found_notfound.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:agent_app/globals.dart' as globals;


/// Builds the UI elements for fetching store information for verification.
/// Store can be fetched using phone number or scanner QR code assigned to store.
class FetchStoreState{
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String num = "1223";
  Uint8List bytes = Uint8List(200);

  Widget buildFetchStore(BuildContext context){
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return _buildFetchStorePortraitView(context);
      } else {
        return _buildFetchStoreLandScapeView(context);
      }
    });
  }

  /// Builds portrait view.
  Widget _buildFetchStorePortraitView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          _buildPhoneChild(context),
          SizedBox(
            height: 10,
          ),
          _buildQRChild(context)
        ],
      ),
    );
  }

  /// Builds landscape view.
  Widget _buildFetchStoreLandScapeView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          _buildPhoneChild(context),
          SizedBox(
            width: 20,
          ),
          _buildQRChild(context)
        ],
      ),
    );
  }

  /// Fetches store details using phone number of store.
  /// If store number is registered in database, it calls [MerchantFound]
  /// interface otherwise it calls [MerchantNotFound] interface.
  Widget _buildPhoneChild(BuildContext context) {
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
                    alignment: Alignment.topCenter,
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
                  child:Align(
                    alignment: Alignment.topCenter,
                  child: Text(
                    "Enter the phone number with which the merchant registered the store.",
                    textAlign: TextAlign.left,
                  ),
                ),
                ),
                Expanded(
                  flex: 2,
                    child:Align(
                      alignment: Alignment.topCenter,
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
                    child:Align(
                      alignment: Alignment.center,
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
                  ),
                )
              ]),
        ),
      ),
    );
  }

  Widget _buildQRChild(BuildContext context) {
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
                          onPressed: () async {
                            await _scan(context);
                            },
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
  Future _scan(BuildContext context) async {
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
}
