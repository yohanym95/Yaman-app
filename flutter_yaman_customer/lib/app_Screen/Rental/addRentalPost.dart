import 'package:firebase_database/firebase_database.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddRental extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddRentalState();
  }
}

class AddRentalState extends State<AddRental> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final prefix0.DatabaseReference databaseReference =
      prefix0.FirebaseDatabase.instance.reference().child('Rental_post');
  
  final homeScaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> savePost(ScaffoldState scaffold) async {
    String date = DateFormat.yMMMd().format(DateTime.now());
    var post = <String, dynamic>{
      'title': titleController.text,
      'description': descriptionController.text,
      'date': date
    };
    // _animateToUser();
    return databaseReference.push().set(post).then((onValue){
      scaffold.showSnackBar(
          new SnackBar(content: new Text("Your Post uploaded")));
          descriptionController.clear();
          titleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Text('Add Rental Post'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                // style: textStyle,
                onChanged: (value) {},
                decoration: InputDecoration(
                    labelText: 'Title',
                    // labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                maxLines: 5,
                // style: textStyle,
                onChanged: (value) {},
                decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Save', textScaleFactor: 1.5),
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        savePost(homeScaffoldKey.currentState);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
