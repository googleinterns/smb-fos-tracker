import 'dart:typed_data';
import 'package:agent_app/agent_views/merchant_found_notfound.dart';
import 'package:agent_app/custom_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:agent_app/agent_datamodels/globals.dart' as globals;
import 'package:qrscan/qrscan.dart' as scanner;

class FetchStore extends StatefulWidget{
  FetchStoreState createState() => FetchStoreState();
}

/// Builds the UI elements for fetching store information for verification.
/// Store can be fetched using phone number or scanner QR code assigned to store.
class FetchStoreState extends State<FetchStore>{
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String num = "1223";
  Uint8List bytes = Uint8List(200);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(globals.agent.getName(), Colors.white),
        body: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                Center(
                  child: Text(
                    "FETCH STORE DETAILS FOR VERIFICATION",
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Text("Method 1"),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Phone Number",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text(
                          "Enter the phone number with which the merchant registered the store.",
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 8,),
                        Container(
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number){
                              num = (number.phoneNumber).toString();
                            },
                            initialValue: number,
                          ),
                        ),
                        SizedBox(height: 8,),
                        /// Fetches store details using phone number of store.
                        /// If store number is registered in database, it calls [MerchantFound]
                        /// interface otherwise it calls [MerchantNotFound] interface.
                        Center(
                          child: ButtonTheme(
                            minWidth: 200,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                if (num == "+919999999999"){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MerchantFound(name: "Alice Peterson",),
                                    ),
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MerchantNotFound(),
                                    ),
                                  );
                                }
                              },
                              textColor: Colors.white,
                              color: Colors.blue,
                              child: new Text("Submit"),
                            ),
                          ),
                        ),
                      ]
                  ),
                ),
                SizedBox(height: 20,),
                Text("Method 2"),
                /// Calls [_scan] function to scan QR code of store
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Scan QR code",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8,),
                      Text(
                        "QR Code is generated when the merchant registers the store using merchant app",
                      ),
                      SizedBox(
                        child: Image.memory(bytes),
                      ),
                      SizedBox(height: 8,),
                      Center(
                        child: ButtonTheme(
                          minWidth: 200,
                          height: 50,
                          child: RaisedButton(
                              onPressed: _scan,
                              textColor: Colors.white,
                              color: Colors.blue,
                              child: new Text("Scan QR Code"),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
                SizedBox(height: 30,),
                Image.asset(
                  "assets/agent_beginning_images/GPay_logo_rectangle.png",
                  height: 40,
                )
              ],
            )
        );
  }
  /// Fetches text of QR code by calling scan() API of qr_scan plugin.
  /// Navigate to [MerchantFound] interface if [qrcode] is registered with any store,
  /// else navigate to [MerchantNotFound] interface.
  Future _scan() async {
    String qrcode = await scanner.scan();
    //Use QR code to get store, if store is registered, pass merchant name found, else not found
    Navigator.pop(context);
    if(qrcode == "73"){      //73 is a hard coded as a valid store QR code currently
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantFound(name: "Alice Peterson"),
        ),
      );
    }
    else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantNotFound(),
        ),
      );
    }
  }
}