import 'dart:convert';
import 'package:agent_app/business_verification_data/Coordinates.dart';
import 'package:agent_app/business_verification_data/verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:agent_app/globals.dart' as globals;
import 'package:agent_app/business_verification_views/business_verification_menu_items.dart';
import 'package:agent_app/business_verification_views/business_verification_success_view.dart';
import 'package:agent_app/business_verification_views/business_verification_failure_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:agent_app/agent_views/welcome_agent.dart';

/// Displays Verification home page for a Merchant that FOS Agent verifies.
///
/// FOS Agent Verifies the Merchant by checking whether Merchant details like address,
/// phone are correct or not.
class VerificationHomeView extends StatefulWidget {
  @override
  _VerificationHomeViewState createState() => _VerificationHomeViewState();
}

/// This enum type is used to select icon for header items.
enum iconType{
  face,
  store,
  phone
}

/// This enum type is used to select text for buttons that describe the type of verification.
enum verificationType{
  finish,
  revisit,
  store_does_not_exist,
  cancel
}

/// This enum type describes the text for different header items.
enum headerName{
  merchant_details,
  business_details,
  business_phone
}

class _VerificationHomeViewState extends State<VerificationHomeView> {

  /// [isNameCorrect] stores whether Merchant name displayed is correct or not.
  bool isNameCorrect = false;

  /// [isAddressCorrect] stores whether Merchant address displayed is correct or not.
  bool isAddressCorrect = false;

  /// [isPhoneCorrect] stores whether Store phone displayed is correct or not.
  bool isPhoneCorrect = false;

  /// [headerHeight] defines the height of header.
  double headerHeight = 50;

  /// [headerTextSize] defines the size of header text.
  double headerTextSize = 14;

  /// [buttonHeight] defines the height of buttons shown at the end of verification page.
  double buttonHeight = 50;

  /// [buttonTextSize] defines the size of text on buttons.
  double buttonTextSize = 17;

  /// [itemHeight] defines the height of item under header.
  double itemHeight = 100;

  /// [itemTextSize] defines the size of text on item under header.
  double itemTextSize = 12;

  /// [appbarHeight] defines the expanded appbar height.
  double appbarHeight = 150;

  /// Builds the main scaffold of verification view.
  ///
  /// Main verification view contains Sliver app bar and Sliver list.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSilverAppBar(appbarHeight),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index > 9) return null;
                switch (index) {
                  case 0:
                    return _buildHeaderItem(headerHeight, headerTextSize, iconType.face, headerName.merchant_details);
                  case 1:
                    return _buildListItem(itemHeight, itemTextSize, headerName.merchant_details);
                  case 2:
                    return _buildHeaderItem(headerHeight, headerTextSize, iconType.store, headerName.business_details);
                  case 3:
                    return _buildListItem(itemHeight+20, itemTextSize, headerName.business_details);
                  case 4:
                    return _buildHeaderItem(headerHeight, headerTextSize, iconType.phone, headerName.business_phone);
                  case 5:
                    return _buildListItem(itemHeight, itemTextSize, headerName.business_phone);
                  case 6:
                    return _buildButtonItem(buttonHeight, buttonTextSize, verificationType.finish);
                  case 7:
                    return _buildButtonItem(buttonHeight, buttonTextSize, verificationType.revisit);
                  case 8:
                    return _buildButtonItem(buttonHeight, buttonTextSize, verificationType.store_does_not_exist);
                  case 9:
                    return _buildButtonItem(buttonHeight, buttonTextSize, verificationType.cancel);
                  default:
                    return null;
                }
              },
            ),
          )
        ],
      ),
    );
  }

  /// SilverAppBar displaying Merchant Name and pins the app bar to screen while scrolling.
  ///
  /// Takes height of the appbar as parameter.
  /// Contains leading back button and pop up menu on the right.
  SliverAppBar _buildSilverAppBar(double height) {
    double expandedHeight = height;
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
            globals.store.storeName,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
            ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[_buildPopUpMenu()],
    );
  }

  /// Defines action to be taken when pop up menu items are selected.
  void choiceAction(String choice) {
    if (choice == VerificationMenuItems.Cancel) {
      //When ever user clicks on discard verification it opens up verification failed
      _showCancelVerificationDialog();
    }
  }

  /// Builds pop up menu.
  PopupMenuButton _buildPopUpMenu() {
    return PopupMenuButton<String>(
      onSelected: choiceAction,
      itemBuilder: (BuildContext context) {
        return VerificationMenuItems.choices.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  /// Builds header item ( Eg: MERCHANT DETAILS ).
  ///
  /// Takes height of item, text size, leading icon and header name as parameters.
  /// Builds header item with specified leading icon and text.
  Widget _buildHeaderItem(double height, double textSize, iconType icon, headerName name){
    return Padding(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
      child: Container(
        height: height,
        child: Row(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.contain, // otherwise the logo will be tiny
              child: _selectIcon(icon),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  _getHeaderText(name),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  /// Selects icon to be returned based on icon type.
  ///
  /// Takes icon as parameter.
  /// Returns Icon widget with face icon when face icon type is passed.
  /// Returns Icon widget with phone icon when phone icon type is passed.
  /// Returns Icon widget with store icon when store icon type is passed.
  Widget _selectIcon(iconType icon){
    switch(icon){
      case iconType.face:
        return Icon(
          Icons.face,
          color: Colors.black54,
        );
      case iconType.phone:
        return Icon(
          Icons.phone,
          color: Colors.black54,
        );
      case iconType.store:
        return Icon(
          Icons.store,
          color: Colors.black54,
        );
    }
  }

  /// Builds button with custom border based on the type given.
  ///
  /// Takes height of button, text size on button and type of verification as parameters.
  /// Returns the button widget.
  /// calls _actonForSelectedVerificationType when pressed on button.
  Widget _buildButtonItem(double height, double textSize,verificationType type) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
      child: Container(
        height: height,
        child: OutlineButton(
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
          highlightedBorderColor: Colors.black,
          onPressed: () {
            _actionForSelectedVerificationType(type);
          },
          child: Text(
            _getVerificationTypeText(type),
            style: TextStyle(
              color: Colors.blue,
              fontSize: textSize,
            ),
          ),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  /// Defines action to be taken when clicked on button given its type.
  void _actionForSelectedVerificationType(verificationType type){
    switch(type){
      case verificationType.finish:
        _showVerifyMerchantDialog();
        break;
      case verificationType.cancel:
        _returnToHome();
        break;
      case verificationType.revisit:
        _sendVerificationData(globals.verificationStatus.needs_revisit);
        _returnToHome();
        break;
      case verificationType.store_does_not_exist:
        _sendVerificationData(globals.verificationStatus.failure);
        _verificationFailed();
        break;
    }
  }

  /// Return to home page.
  void _returnToHome(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WelcomeAgent()));
  }

  /// Sets verification data that is to be sent to server.
  void _sendVerificationData(globals.verificationStatus status){

    globals.newVerification = new Verification();

    globals.newVerification.status = status;
    globals.newVerification.storePhone = globals.store.phone;
    globals.newVerification.agentEmail = globals.agent.AgentEmail;

    globals.newVerification.verificationCoordinates = new Coordinates();
    _setCurrentLocationCoordinates();

  }

  /// Gets the present location from geo coordinates during verification.
  void _setCurrentLocationCoordinates() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        globals.newVerification.verificationCoordinates.latitude = position.latitude;
        globals.newVerification.verificationCoordinates.longitude = position.longitude;
        String verificationString = globals.newVerification.convertToJsonString();
        print(verificationString);
        _sendDataToServer(verificationString);
      });
        }).catchError((e) {
      print(e);
    });
  }

  /// Sends the data to server.
  void _sendDataToServer(String body) async{
    http.Response response = await http.post(
        'https://fos-tracker-278709.an.r.appspot.com/verifications/new',
        body: body
    );

    if(response.statusCode == 200){
      print('successful insert');
    }else{
      print('try again');
    }
  }

  /// Returns the text on button to be displayed based on type of verification.
  String _getVerificationTypeText(verificationType type){
    switch(type){
      case verificationType.finish:
        return 'Finish Verification';
      case verificationType.revisit:
        return 'Needs another visit';
      case verificationType.store_does_not_exist:
        return 'Store does not exist';
      case verificationType.cancel:
        return 'Cancel';
    }
  }

  /// Returns the text to be displayed on header based on header name.
  String _getHeaderText(headerName name){
    switch(name){
      case headerName.merchant_details:
        return 'MERCHANT DETAILS';
      case headerName.business_details:
        return 'BUSINESS DETAILS';
      case headerName.business_phone:
        return 'BUSINESS PHONE';
    }
  }

  /// Builds list item under header based on header name.
  ///
  /// Takes item height, text size and header name as parameters.
  /// Contains text with trailing icons (correct or wrong).
  Widget _buildListItem(double itemHeight, double textSize, headerName name) {
    return Padding(
        padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
        child: Container(
          height: itemHeight,
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 4,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                _getFieldName(name),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Padding(
                              padding: EdgeInsets.only(top: 5),
                              child:Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    _getFieldValue(name),
                                  )
                              )
                          )
                      )
                    ],
                  )
              ),
              Expanded(
                  flex: 2,
                  child: _buildIcons(name)
              )
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        )
    );
  }

  /// Returns the text to be displayed on header based on header name.
  String _getFieldName(headerName name){
    switch(name){
      case headerName.merchant_details:
        return 'Merchant Name';
      case headerName.business_details:
        return 'Address';
      case headerName.business_phone:
        return 'Phone Number';
    }
  }

  /// Returns the value of the field fetched from server to be displayed based on header name.
  String _getFieldValue(headerName name){
    switch(name){
      case headerName.merchant_details:
        return globals.store.ownerName.getName();
      case headerName.business_details:
        return globals.store.storeAddress.getAddress();
      case headerName.business_phone:
        return globals.store.phone;
    }
  }

  /// Returns the variable value that defines correct or wrong button to be highlighted.
  bool _getVariableValue(headerName name){
    switch(name){
      case headerName.merchant_details:
        return isNameCorrect;
      case headerName.business_details:
        return isAddressCorrect;
      case headerName.business_phone:
        return isPhoneCorrect;
    }
  }

  /// Sets the corresponding value of boolean variable based on header name.
  void _setVariableValue(headerName name, bool value){
    switch(name){
      case headerName.merchant_details:
        isNameCorrect = value;
        break;
      case headerName.business_details:
        isAddressCorrect = value;
        break;
      case headerName.business_phone:
        isPhoneCorrect = value;
        break;
    }
  }

  /// Builds correct and wrong icons.
  ///
  /// Takes header name as parameter.
  /// Based on header name updates and gets corresponding value.
  Widget _buildIcons(headerName name){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: InkWell(
            splashColor: Colors.white,
            onTap: (){
              _setVariableValue(name,false);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                color: !_getVariableValue(name) ? Colors.red[100] : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: !_getVariableValue(name) ? Colors.red : Colors.blue,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child:InkWell(
            splashColor: Colors.white,
            onTap: (){
              _setVariableValue(name,true);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                color: _getVariableValue(name) ? Colors.green[100] : Colors.white,
                shape: BoxShape.circle,
              ),
              child:Icon(
                Icons.done,
                color: _getVariableValue(name) ? Colors.green : Colors.blue,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Displays dialog box confirms whether FOS Agent want to delete verification or not.
  ///
  /// Dialog box contains CANCEL and DELETE buttons.
  /// If CANCEL is selected Agent remains on same page
  /// If DELETE is selected then it deletes the verification.
  Future<void> _showCancelVerificationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Delete the verification'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('DELETE'),
               onPressed: () {
                 _returnToHome();
               },
            ),
          ],
        );
      },
    );
  }

  /// Displays dialog box confirms whether FOS Agent want to verify or not.
  ///
  /// Dialog box contains CANCEL and VERIFY buttons.
  /// If CANCEL is selected Agent remains on same page
  /// If VERIFY is selected then Merchant details are verified.
  Future<void> _showVerifyMerchantDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Verify the merchant'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('VERIFY'),
              onPressed: () {
                _verifyMerchant();
              },
            ),
          ],
        );
      },
    );
  }

  /// Verifies Merchant.
  ///
  /// If [isBusinessPresent] and [isStorePresent] are true then displays [VerificationSuccessView]
  /// else displays [VerificationFailureView].
  void _verifyMerchant() {
    if (isAddressCorrect & isPhoneCorrect & isNameCorrect) {
      _sendVerificationData(globals.verificationStatus.success);
      _verificationSuccess();
    } else {
      _sendVerificationData(globals.verificationStatus.failure);
      _verificationFailed();
    }
  }

  /// Navigates to verification success page.
  void _verificationSuccess(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VerificationSuccessView()));
  }

  /// Navigates to verification failure page.
  void _verificationFailed(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VerificationFailureView()));
  }
}
