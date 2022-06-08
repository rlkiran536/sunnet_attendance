// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sunnet_attendance/models/user_model.dart';

import '../main.dart';
import 'home_screen.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;
  late String username;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        UserModel user = UserModel();
        user.phone = authCredential.user?.phoneNumber;
        user.uid = authCredential.user?.uid;
        user.username = usernameController.text.trim().toLowerCase();
        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        await firebaseFirestore
            .collection("usersV2")
            .doc(authCredential.user?.uid)
            .set(user.toMap())
            .then((value) {
          Fluttertoast.showToast(msg: "Success");
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        // Navigator.popUntil(context, ModalRoute.withName('/'));
      }
      //  else {
      //   Fluttertoast.showToast(msg: authCredential.user.toString());
      // }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      Fluttertoast.showToast(msg: e.message.toString());
      // _scaffoldKey.currentState
      //     .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  getMobileFormWidget(context) {
    return Column(
      children: [
        const Spacer(),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            hintText: "Enter Username",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "Enter Phone Number",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () async {
            if (usernameController.text.isEmpty ||
                usernameController.text.length < 2 ||
                phoneController.text.length > 10 ||
                phoneController.text.length < 10) {
              Fluttertoast.showToast(msg: 'Invalid input ');
            } else {
              setState(() {
                showLoading = true;
              });
              await _auth.verifyPhoneNumber(
                phoneNumber: '+91' + phoneController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  //signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (verificationFailed) async {
                  setState(() {
                    showLoading = false;
                  });
                  Fluttertoast.showToast(
                      msg: verificationFailed.message.toString(),
                      toastLength: Toast.LENGTH_LONG);

                  // _scaffoldKey.currentState.showSnackBar(
                  //     SnackBar(content: Text(verificationFailed.message)));
                },
                codeSent: (verificationId, resendingToken) async {
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationId = verificationId;
                  });
                },
                codeAutoRetrievalTimeout: (verificationId) async {},
              );
            }
          },
          child: const Text("Register"),
        ),
        const Spacer(),
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        const Spacer(),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: otpController.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: const Text("VERIFY"),
        ),
        const Spacer(),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Registration Form'),
        ),
        body: Container(
          child: showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                  ? getMobileFormWidget(context)
                  : getOtpFormWidget(context),
          padding: const EdgeInsets.all(16),
        ));
  }
}
