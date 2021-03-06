/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'dart:convert';

import 'package:agent_app/agent_datamodels/name.dart';
import 'package:agent_app/agent_datamodels/address.dart';
import 'package:agent_app/agent_datamodels/coordinates.dart';
import 'package:http/http.dart' as http;
import 'package:agent_app/globals.dart' as globals;
import 'coordinates.dart';

/// Store model that stores the Store fetched from spanner database.
class Store {
  Name ownerName;
  String email;
  String storeName;
  Address storeAddress;
  MapCoordinates storeCoordinates;
  String phone;
  String creationDateTime;

  Store(
      { this.ownerName,
        this.email,
        this.storeAddress,
        this.storeCoordinates,
        this.phone,
        this.storeName,
        this.creationDateTime
      });

  /// Creates new Store object from json string.
  factory Store.fromJson(Map<String, dynamic> json) {
    return new Store(
        ownerName: Name.fromJson(json['ownerName']),
        email: json['email'],
        storeAddress: Address.fromJson(json['storeAddress']),
        storeCoordinates: MapCoordinates.fromJson(json['coordinates']),
        phone: json['phone'],
        storeName: json['storeName'],
        creationDateTime: json['creationDateTime']
    );
  }

  /// Fetches store from the spanner database.
  static Future<Null> fetchStore(String phone) async {
    var response = await http.post(
        "https://fos-tracker-278709.an.r.appspot.com/store/phone",
        body: jsonEncode(<String, String> {"storePhone": phone}));
    if (response.statusCode == 200) {
      print('The Store exists with given phone number');
      try {
        LineSplitter lineSplitter = new LineSplitter();
        List<String> lines = lineSplitter.convert(response.body);
        String jsonString = lines[0];
        globals.isStorePresent = true;
        globals.store = Store.fromJson(jsonDecode(jsonString));
      } catch (e) {
        print(e);
      }
    } else {
      print('Store Phone number not found');
      globals.isStorePresent = false;
    }
  }
}
