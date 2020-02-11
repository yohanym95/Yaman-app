import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber/main.dart';

class DriverManagement {
  Future<bool> addData(userData, userId, context) async {
    FirebaseDatabase.instance
        .reference()
        .child('Drivers')
        .child(userId)
        .set(userData)
        .then((onValue) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => false,
      );
      return false;
    }).catchError((onError) {
      return false;
    });

    return false;
  }
}
