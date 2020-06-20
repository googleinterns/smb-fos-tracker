import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'business_location_page.dart';
import 'globals.dart' as globals;
import 'name.dart';
import 'store.dart';

class BusinessDetailsPageOne extends StatefulWidget {
  @override
  _BusinessDetailsPageOneState createState() => _BusinessDetailsPageOneState();
}

/*
 * This class contains the view to accept basic business details such as:
 * Business owner's name,
 * Store/Business name.
 * It has validation to check whether all fields have been filled.
 */
class _BusinessDetailsPageOneState extends State<BusinessDetailsPageOne> {
  TextEditingController storeNameController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  final formValidationKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextStyle montserratBoldStyle =
        GoogleFonts.montserrat(fontWeight: FontWeight.w500);
    TextStyle montserratBasicStyle = GoogleFonts.montserrat();
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: formValidationKey,
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                  screenHeight * 0.01, screenWidth * 0.05, screenHeight * 0.05),
              child: ListView(
                children: <Widget>[
                  Text(
                    "Business details (1/3)",
                    style: montserratBoldStyle.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Tell us more about your business",
                    style: montserratBoldStyle.copyWith(
                      color: Colors.black26,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: (screenHeight * 0.03),
                  ),
                  SizedBox(
                    height: (screenHeight * 0.015),
                  ),
                  TextFormField(
                    controller: storeNameController,
                    style: montserratBasicStyle,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Cannot be empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Shop name',
                      hintStyle: montserratBasicStyle,
                    ),
                  ),
                  Text(
                    "Name that your customers will see",
                    style: montserratBoldStyle.copyWith(
                      color: Colors.black26,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: (screenHeight * 0.015),
                  ),
                  TextFormField(
                    controller: ownerNameController,
                    style: montserratBasicStyle,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Cannot be empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Business owner\'s name',
                      hintStyle: montserratBasicStyle,
                    ),
                  ),
                  Text(
                    "Name of owner, director or partner",
                    style: montserratBoldStyle.copyWith(
                      color: Colors.black26,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: (screenHeight * 0.015),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        splashColor: Colors.blueAccent,
                        onPressed: () {
                          if (formValidationKey.currentState.validate()) {
                            List<String> inputNameParts =
                                ownerNameController.text.split(" ");

                            String inputFirstName = "";
                            String inputLastName = "";
                            String inputMiddleName = "";
                            int i = 0;
                            for (var part in inputNameParts) {
                              i++;
                              if (i == 1) {
                                inputFirstName = part;
                              }
                              if (i == 2) {
                                inputMiddleName = part;
                              }
                              if (i == 3) {
                                inputLastName = part;
                              }
                            }
                            Store store = new Store(
                                new Name(inputFirstName, inputMiddleName,
                                    inputLastName),
                                globals.googleSignIn.currentUser.email,
                                null,
                                null,
                                null,
                                storeNameController.text);
                            globals.store = store;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BusinessDetailsPageTwo()));
                          }
                        },
                        child: Text(
                          "Next",
                          style: montserratBasicStyle,
                        ),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
