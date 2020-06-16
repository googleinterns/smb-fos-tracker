/// Global library for storing details that remain common through all views
/// of application. [googleSignIn] is google account details of agent signed
/// in. [agent] is the agent registered with [googleSignIn.email]

library gpay_agent.globals;

import 'package:agent_app/agent_datamodels/agent.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
Agent agent;
int merchantsVerifiedbyAgent = 0;
