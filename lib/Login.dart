import 'package:authentification/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MobileVerificationState{
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async{
    
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if(authCredential?.user != null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
      }

    } on FirebaseAuthException catch (e) {

      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  getMobileFormWidget(context){
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: "Phone Number",
          ),
        ),
        SizedBox(
          height: 16,
          ),
        FlatButton(
          onPressed: () async{

            setState(() {
              showLoading = true;
            });

            await _auth.verifyPhoneNumber(
              phoneNumber: phoneController.text, 
              verificationCompleted: (phoneAuthCredential) async{
                setState(() {
                  showLoading = false;
                });
              }, 
              verificationFailed: (verificationFailed) async{
                setState(() {
                  showLoading = false;
                });
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(verificationFailed.message)));
              }, 
              codeSent: (verifictionId, resendingToken) async{
                setState(() {
                  showLoading = false;
                  currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                  this.verificationId = verificationId;
                });
              }, 
              codeAutoRetrievalTimeout: (verificationId) async{

              }
              );
          }, 
          child: Text("Send"),
          color: Colors.red,
          textColor: Colors.white,
          ),
        Spacer(),
      ],
    );
  }

  getOtpFormWidget(context){
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        SizedBox(
          height: 16,
          ),
        FlatButton(
          onPressed: () async{
            PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
          }, 
          child: Text("Verify"),
          color: Colors.red,
          textColor: Colors.white,
          ),
        Spacer(),
      ],
    );

  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        body: Container(
      child: showLoading ? Center(child: CircularProgressIndicator(),) : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE 
          ? getMobileFormWidget(context):
            getOtpFormWidget(context),
      padding: const EdgeInsets.all(16),
    )
    );
  }


}
