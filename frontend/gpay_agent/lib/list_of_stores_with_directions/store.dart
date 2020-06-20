import 'package:agent_app/list_of_stores_with_directions/coordinate.dart';

/// Stores the store object that is fetched from spanner.
class Store {
  String storePhone;
  Coordinates coordinates;
  String status;
  String storeName;

  Store({this.storePhone, this.coordinates, this.status, this.storeName});

  factory Store.fromJson(Map<String, dynamic> json) {
    return new Store(
        storePhone: json['phone'],
        coordinates: Coordinates.fromJson(json['coordinates']),
        storeName: json['storeName'],
        status: json['verificationStatus']);
  }
}
