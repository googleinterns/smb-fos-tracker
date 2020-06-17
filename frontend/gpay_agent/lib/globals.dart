/// Global library for storing details that remain common through all views
/// of application. [googleSignIn] is google account details of agent signed
/// in. [agent] is the agent registered with [googleSignIn.email]

library gpay_agent.globals;
import 'package:agent_app/agent_datamodels/agent.dart';
import 'package:agent_app/business_verification_data/Coordinates.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:agent_app/agent_datamodels/name.dart';
import 'package:agent_app/agent_datamodels/coordinates.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
Agent agent;
int merchantsVerifiedbyAgent = 0;

/*Agent agent = new Agent(
'vahinimirididdi@gmail.com',
new Name("","",'Vahini'),
'9490146571',
'12:00 AM',
new MapCoordinates(12, 13));*/