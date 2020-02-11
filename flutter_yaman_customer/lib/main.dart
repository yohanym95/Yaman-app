import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yaman_driver/app_Screen/Rental/rental.dart';
import 'package:flutter_yaman_driver/app_Screen/login/login_screen.dart';
import 'package:flutter_yaman_driver/logic/auth.dart';
import 'package:flutter_yaman_driver/getMap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String uId = userId;
  String userName;

  @override
  void initState() {
    // print(uId + '   $userName');
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) => {
          if (currentUser == null)
            {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginHome()),
                (Route<dynamic> route) => false,
              )
            }
          else
            {userName = currentUser.displayName}
        });
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut().then((onValue) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginHome()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('Yaman'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: "Logout",
            onPressed: () async {
              signOut();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          //    mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Hi $userName !'),
            CarouselSlider(
              height: 400,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              items: <Widget>[
                GestureDetector(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Image.asset('images/tuktukvehicle.png'),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Rides',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GetMap()));
                  },
                ),
                GestureDetector(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Image.asset('images/bikerental.png'),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Rental',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Rental()));
                  },
                ),
                GestureDetector(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Image.asset('images/payment.png'),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'History',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  onTap: () {},
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
