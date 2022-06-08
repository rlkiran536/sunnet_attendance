// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/log_model.dart';

getCurrentLocation() async {
  var status = await Geolocator.requestPermission();
  print(status);

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
