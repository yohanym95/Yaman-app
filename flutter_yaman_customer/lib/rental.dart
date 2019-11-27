import 'package:flutter/material.dart';
import 'package:flutter_yaman_driver/addRentalPost.dart';

class Rental extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RentalState();
  }
}

class RentalState extends State<Rental> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental'),
      ),
      body: Container(
          child: ListView(
        children: <Widget>[],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddRental()));
        },
      ),
    );
  }
}
