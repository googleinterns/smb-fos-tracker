/// Global library for storing details that remain common through all views
/// of application. [googleSignIn] is google account details of agent signed
/// in. [agent] is the agent registered with [googleSignIn.email]

library gpay_agent.globals;
import 'package:agent_app/agent_datamodels/agent.dart';
import 'package:agent_app/business_verification_data/verification.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:agent_app/agent_datamodels/name.dart';
import 'package:agent_app/agent_datamodels/coordinates.dart';

import 'agent_datamodels/store.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
//Agent agent;
int merchantsVerifiedbyAgent = 0;
bool isStorePresent = false;

Agent agent = new Agent(
'vahinimirididdi@gmail.com',
new Name("vahini", "", "k"),
'9490146571',
'12:00 AM',
new MapCoordinates(13, 14));


Store store;

enum verificationStatus{
  success,
  failure,
  needs_revisit,
  not_verified
}

Verification newVerification;