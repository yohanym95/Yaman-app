import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yaman_driver/logic/auth.dart';
import 'package:flutter_yaman_driver/app_Screen/profile/createprofile.dart';
import 'package:flutter_yaman_driver/main.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginHome extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  bool _isLoading = false;

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //   signedIn();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Stack(
          children: <Widget>[clipper(), loginDetails()],
        ),
      ),
    );
  }

  List<Color> colorGradient = [
    Colors.purple[100],
    Colors.purple[200],
    Colors.purple[300],
  ];

  Widget loginDetails() {
    return Container(
      alignment: Alignment.center,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 100,
                height: 100,
                child: Image.asset('images/tuktukvehicle.png')),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Yaman',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'coiny',
                      color: Colors.indigo),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Login With',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'coiny',
                      color: Colors.black),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(right: 30, left: 30),
                child: _signInButton()),
          ],
        ),
      ),
    );
  }

  Widget clipper() {
    return ClipPath(
      clipper: TopClipper(),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: colorGradient,
                begin: Alignment.topLeft,
                end: Alignment.topCenter)),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        setState(() {
          _isLoading = true;
        });
        check();
        // signInWithGoogle();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("images/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  check() {
    DatabaseReference database =
        FirebaseDatabase.instance.reference().child('Users');

    signInWithGoogle().then((onValue) {
      String uid = userId;

      if (uid == null) {
        print('login uid :$uid');
      }

      database.once().then((DataSnapshot data) {
        if (data.value == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
            (Route<dynamic> route) => false,
          );
        } else {
          var Data1 = data.value.keys;

          print(Data1);

          for (var key in Data1) {
            if (key == uid) {
              // setState(() async {
              //   _isLoading = false;
              // });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                (Route<dynamic> route) => false,
              );

              print('homepage');
              break;
            } else {
              // setState(() async {
              //   _isLoading = false;
              // });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
                (Route<dynamic> route) => false,
              );

              print('profile');
            }
          }
        }
      });
    }).catchError((onError) {
      setState(() async {
        _isLoading = false;
        print('error');
      });
      print('error');
      print(onError.toString());
    });

    // setState(() {
    //   print(postList.length);
    // });
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - size.height / 6);

    // //creating first curver near bottom left corner
    // var firstControlPoint = new Offset(size.width / 7, size.height - 30);
    // var firstEndPoint = new Offset(size.width / 6, size.height / 1.5);

    // path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
    //     firstEndPoint.dx, firstEndPoint.dy);

    //creating second curver near center
    var secondControlPoint = Offset(size.width / 5, size.height / 4);
    var secondEndPoint = Offset(size.width / 1.5, size.height / 5);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    //creating third curver near top right corner
    var thirdControlPoint =
        Offset(size.width - (size.width / 10), size.height / 6);
    var thirdEndPoint = Offset(size.width, 0.0);

    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    ///move to top right corner
    path.lineTo(size.width, 0.0);

    ///finally close the path by reaching start point from top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
