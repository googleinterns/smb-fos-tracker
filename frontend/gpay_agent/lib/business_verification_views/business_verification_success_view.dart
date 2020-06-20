import 'package:flutter/material.dart';
import 'package:agent_app/agent_views/welcome_agent.dart';

/// Displays Verification success page.
class VerificationSuccessView extends StatefulWidget {
  _VerificationSuccessViewState createState() =>
      _VerificationSuccessViewState();
}

class _VerificationSuccessViewState extends State<VerificationSuccessView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
        leading: IconButton(
          icon: Icon(Icons.home,color: Colors.black,),
          onPressed: () {
            _returnToHome();
          },
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation){
          if(orientation == Orientation.portrait){
            return _buildSuccessPortraitView();
          }
          else{
            return _buildSuccessLandScapeView();
          }
        }
      )
    );
  }

  /// Returns to Home.
  void _returnToHome(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WelcomeAgent()));
  }

  /// Builds success landscape view.
  ///
  /// Contains gif and message in a row.
  Widget _buildSuccessLandScapeView(){
    return  Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset('assets/verification_images/thumbs_up_success.gif'),
          )
        ),
        Expanded(
          flex: 1,
          child: const Center(
            child: Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Builds success portrait view.
  ///
  /// Contains gif and message in a row.
  Widget _buildSuccessPortraitView(){
    return  Column(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset('assets/verification_images/thumbs_up_success.gif'),
            )
        ),
        Expanded(
          flex: 1,
          child: const Center(
            child: Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        )
      ],
    );
  }
}
