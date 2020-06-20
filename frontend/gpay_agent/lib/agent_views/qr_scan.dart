//MIT License
//
//Copyright (c) 2019 Shusheng
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import 'dart:async';
import 'dart:typed_data';
import 'package:agent_app/agent_views/merchant_found_notfound.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class QrScan extends StatefulWidget {
  @override
  _QrScanState createState() => _QrScanState();
}

/// Builds UI elements for QR code scan and function [_scan] for calling QR code API.
class _QrScanState extends State<QrScan> {
  String barcode = '';
  Uint8List bytes = Uint8List(200);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Scan Merchant QR Code "),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 200,
                child: Image.memory(bytes),
              ),
              ButtonTheme(
                minWidth: 200,
                height: 50,
                child: RaisedButton(
                  onPressed: _scan,
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: new Text("Scan"),
                ),
              ),
            ],
          ),
        ),
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
}