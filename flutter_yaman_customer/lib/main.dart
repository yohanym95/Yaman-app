import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yaman_driver/getMap.dart';
import 'package:flutter_yaman_driver/rental.dart';

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
      home: MyHomePage(title: 'යමං - Yaman '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  String textValue;

  @override
  void initState() {
    // TODO: implement initState
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print("onLaunch called");
      },
      onResume: (Map<String, dynamic> msg) {
        print("onResume called");
      },
      onMessage: (Map<String, dynamic> msg) {
        print("pnMessage called");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));

    firebaseMessaging.onIosSettingsRegistered.listen((onData) {
      print('IOS Setting registered : ');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
  }

  update(String token) {
    print(token);
    textValue = token;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CarouselSlider(
            height: 380,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            onPageChanged: (index) {
              setState(() {});
            },
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
    );
  }
}
