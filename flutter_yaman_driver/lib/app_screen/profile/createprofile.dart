import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber/logic/auth.dart';
import 'package:flutter_uber/logic/userProfile.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileState();
  }
}

class ProfileState extends State<Profile> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController _firstname = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _currencity = TextEditingController();
  // array for dropdown
  // var _currencies = ['Police', 'Teacher', 'University'];
  // var currencyValue = 'Police';
  //bool for modalprogressHUD
  bool _isLoading = false;

  final DatabaseReference database =
      FirebaseDatabase.instance.reference().child("Users");

  // load profile details
  String url = imageUrl;
  String name1 = name;
  String email1 = email;
  String userId1 = userId;

  @override
  Widget build(BuildContext context) {
    _firstname.text = name1;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.purple[300],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: SingleChildScrollView(
          child: Container(margin: EdgeInsets.all(5), child: createProfileUI()),
        ),
      ),
    );
  }

  // void onClickedItem(String dropdownitem) {
  //   setState(() {
  //     this.currencyValue = dropdownitem;
  //     print(this.currencyValue);
  //   });
  // }

  Widget createProfileUI() {
    _firstname.text = name;
    _email.text = email;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
              child: Center(
            child: Text(
              'Create Your Profile',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal),
            ),
          )),
          url == null
              ? Container(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: Colors.purple[100],
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(url),
                  radius: 60,
                  backgroundColor: Colors.transparent,
                ),
          Container(
            margin: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 15.0, bottom: 5.0, left: 5, right: 5),
                child: TextFormField(
                  controller: _firstname,
                  //style: textStyle,
                  validator: (String Value) {
                    if (Value.isEmpty) {
                      return 'Enter Your First Name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Name',
                      focusColor: Colors.purple,
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: Colors.black),
                      prefixIcon: Icon(Icons.person),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15.0),
                      hintText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 15.0, bottom: 5.0, left: 5, right: 5),
                child: TextFormField(
                  controller: _email,
                  //style: textStyle,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Enter Your Email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Email',
                      focusColor: Colors.purple,
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: Colors.black),
                      prefixIcon: Icon(Icons.person),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15.0),
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                )),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Row(
          //     children: <Widget>[
          //       Expanded(
          //           flex: 1,
          //           child: Text(
          //             'Category',
          //             style: TextStyle(color: Colors.black, fontSize: 15),
          //           )),
          //       Expanded(
          //         flex: 4,
          //         child: Card(
          //           child: DropdownButton<String>(
          //             isExpanded: true,
          //             items: _currencies.map((String dropDownStringItem) {
          //               return DropdownMenuItem<String>(
          //                   value: dropDownStringItem,
          //                   child: Text(
          //                     dropDownStringItem,
          //                     textAlign: TextAlign.center,
          //                   ));
          //             }).toList(),
          //             onChanged: (String dropdownitem) {
          //               onClickedItem(dropdownitem);
          //             },
          //             value: currencyValue,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            margin: EdgeInsets.all(5),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5, right: 5),
                child: TextFormField(
                  controller: _currencity,
                  //style: textStyle,
                  validator: (String Value) {
                    if (Value.isEmpty) {
                      return 'Enter Your Current City';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Current City',
                      focusColor: Colors.purple,
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: Colors.black),
                      prefixIcon: Icon(Icons.person),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15.0),
                      hintText: "Current City",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 5),
            width: double.infinity,
            child: MaterialButton(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 8, left: 10, right: 10),
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  print(_firstname.text);
                  print(_email.text);
                  // print(this.currencyValue);
                  print(_currencity.text);

                  DriverManagement().addData({
                    'fullName': _firstname.text,
                    'email': _email.text,
                    'currentCity': _currencity.text,
                    'photoUrl': url
                  }, userId1, context).then((onValue) {
                    setState(() {
                      _isLoading = onValue;
                      print(onValue);
                    });
                  }).catchError((onError) {
                    setState(() {
                      _isLoading = true;
                    });
                  });
                }
              },
              color: Colors.purple[300],
            ),
          ),
        ],
      ),
    );
  }
}
