import 'dart:convert';
import 'package:agent_app/globals.dart' as globals;

import 'package:agent_app/business_verification_data/Coordinates.dart';

class Verification {
  String agentEmail;
  String storePhone;
  Coordinates verificationCoordinates;
  globals.verificationStatus status;

  Verification(
      {this.agentEmail,
        this.storePhone,
        this.verificationCoordinates,
        this.status});

  String convertToJsonString(){
    return jsonEncode( <String ,dynamic>{
      "agentEmail":agentEmail,
      "storePhone":storePhone,
      "verificationCoordinates":{
        "latitude":verificationCoordinates.latitude,
        "longitude":verificationCoordinates.longitude
      },
      "verificationStatus":_getStatus(status)
    });
  }

  String _getStatus(globals.verificationStatus status){
    switch(status){
      case globals.verificationStatus.success:
        return "green";
      case globals.verificationStatus.failure:
        return "red";
      case globals.verificationStatus.needs_revisit:
        return "yellow";
      case globals.verificationStatus.not_verified:
        return "grey";
    }
  }
}