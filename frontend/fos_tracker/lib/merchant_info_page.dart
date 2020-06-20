/*
  This class contains the UI for the view that is generated on clicking on a merchant in the main map or from an agent map.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> getMerchantInfo() async {
    var result = await http.post(
        "https://fos-tracker-278709.an.r.appspot.com/store/phone",
        body: jsonEncode(<String, String>{"storePhone": widget.storePhone}));
    if (result.statusCode != 200) {
      setState(() {});
    } else {
      try {
        LineSplitter lineSplitter = new LineSplitter();
        List<String> lines = lineSplitter.convert(result.body);
        String json = lines[0];
        var jsonDecoded = jsonDecode(json);
        setState(() {
          storeName = jsonDecoded['storeName'];
          ownerName = jsonDecoded['ownerName']['firstName'] +
              ' ' +
              jsonDecoded['ownerName']['middleName'] +
              ' ' +
              jsonDecoded['ownerName']['lastName'];
          storeCreationTime = jsonDecoded['creationDateTime'];
          address = jsonDecoded['storeAddress']['street'] +
              "\n" +
              jsonDecoded['storeAddress']['area'] +
              "\n" +
              jsonDecoded['storeAddress']['city'] +
              "\n" +
              jsonDecoded['storeAddress']['state'] +
              "\n" +
              jsonDecoded['storeAddress']['pincode'] +
              "\n" +
              jsonDecoded['storeAddress']['country'];
        });
      } catch (e) {
        print(e + "error parsing merchant info");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(widget.storePhone),
        ),
        body: storeName == null
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      storeName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Owner: " + ownerName,
                    ),
                    Text(
                      "Phone: " + widget.storePhone,
                    ),
                    Text(
                      "Address: " + address,
                    ),
                    Text(
                      "Creation time: " + storeCreationTime,
                    ),
                  ],
                ),
              ));
  }
}
