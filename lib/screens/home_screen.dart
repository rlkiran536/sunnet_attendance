import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:sunnet_attendance/screens/login_screen.dart';
import 'package:sunnet_attendance/utils/constants.dart' as constants;
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

// import '../main.dart';
import '../models/log_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool currentState = false;
  String buttonTitle = 'START';

  // @override
  // void initState() {
  //   super.initState();
  // }

  startWorkManager() {
    Workmanager().registerPeriodicTask("sendData", "hourly data",
        frequency: const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    void bussinessAction() {
      setState(() {
        currentState = !currentState;
        buttonTitle = currentState ? 'STOP' : 'START';
        if (currentState) {
          getCurrentLocation();
          // startWorkManager();
          // Fluttertoast.showToast(msg: 'Getting location details');
          //   Fluttertoast.showToast(msg: getCurrentLocation());
          //   // content = getCurrentLocation();
        } else {
          // Workmanager().cancelByUniqueName("sendData");
          // FirebaseAuth.instance.signOut();
          // Route route = MaterialPageRoute(builder: (context) => const MyApp());
          // Navigator.pushReplacementNamed(context, "/");
          // Navigator.pop(context);
        }
      });
    }

    logout() async {
      await FirebaseAuth.instance.signOut();
      // Navigator.pushReplacementNamed(context, '/');
      // Workmanager().cancelByUniqueName("sendData");
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text(constants.title)),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: bussinessAction,
            child: Text(buttonTitle),
          ),
          ElevatedButton(
            onPressed: logout,
            child: const Text('Logout'),
          ),
        ],
      )),
    );
  }
}

getCurrentLocation() async {
  await Geolocator.requestPermission();

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);

  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  String address =
      "${placemarks[1].street}, ${placemarks[1].subLocality},${placemarks[1].locality} - ${placemarks[1].postalCode},${placemarks[1].subAdministrativeArea},${placemarks[1].administrativeArea}.";
  // Fluttertoast.showToast(msg: address);
  // return address;
  LogModel log = LogModel();
  log.time = DateTime.now();

  log.lat = position.latitude;
  log.long = position.longitude;
  log.address = address;
  sendData(log);
}

sendData(LogModel log) async {
  var db = FirebaseFirestore.instance;
  await db.collection("usersV2").get().then((event) {
    for (var doc in event.docs) {
      if (FirebaseAuth.instance.currentUser?.uid == doc.id) {
        doc.data().forEach((key, value) {
          if (key == 'uid') log.uid = value;
          if (key == 'username') log.username = value;
          if (key == 'phone') log.phone = value;
        });
      }
      // print("${doc.id} => ${doc.data()}");
    }
  });
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  await firebaseFirestore
      .collection("logsV3")
      .doc()
      .set(log.toMap())
      .then((value) {
    Fluttertoast.showToast(msg: "Success");
  });
}
