/// Global library for storing details that remain common through all views
/// of application. [googleSignIn] is google account details of agent signed
/// in. [agent] is the agent registered with [googleSignIn.email]
/// [newVerification] is verification object that store present verification that is sent

library gpay_agent.globals;

import 'package:agent_app/agent_datamodels/agent.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:agent_app/agent_datamodels/store.dart';

import 'business_verification_data/verification.dart';


GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
Agent agent;
int merchantsVerifiedbyAgent = 0;
bool isStorePresent;
Store store;
enum verificationStatus{
  success,
  failure,
  needs_revisit,
  not_verified
}

Verification newVerification;
