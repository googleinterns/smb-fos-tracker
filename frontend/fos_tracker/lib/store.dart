import 'package:fos_tracker/coordinates.dart';

/*
  This class is a model for a store.
 */
class Store {
  String storePhone;
  Coordinates coordinates;
  String status;

  Store({this.storePhone, this.coordinates, this.status});

  factory Store.fromJson(Map<String, dynamic> json) {
    return new Store(
        storePhone: json['phone'],
        coordinates: Coordinates.fromJson(json['coordinates']),
        status: json['verificationStatus']);
  }
}
