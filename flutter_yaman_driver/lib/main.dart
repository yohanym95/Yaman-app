import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_uber/app_screen/login/login_screen.dart';
import 'package:flutter_uber/getmap.dart';
import 'package:flutter_uber/request/google_map_request.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as prefix0;
import 'package:google_maps_webservice/places.dart';

void main() => runApp(MyApp());

GoogleMapsPlaces _places =
    new GoogleMapsPlaces(apiKey: "AIzaSyAeBZue8ZW1DFyghF7Vw-yTkoV1j8FB-eg");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  GoogleMapController mapController;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  final Set<Marker> _markers = {};
  //polyline
  final Set<Polyline> _polyLine = {};

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final DatabaseReference database = FirebaseDatabase.instance
      .reference()
      .child('Uber')
      .child('drivers_geoPoint');

  final DatabaseReference database1 =
      FirebaseDatabase.instance.reference().child('Uber');

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  String userId;

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      destinationController.text = p.description;
      senRequest(p.description);

      scaffold.showSnackBar(
          new SnackBar(content: new Text("${p.description} - $lat/$lng")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // auth.signInWithEmail(email, password)
    _getUserLocation();
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
            {_getUserLocation(), userId = currentUser.uid}
        });

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

  // create the token for get notification when user request driver
  update(String token) {
    print(token);
    // textValue = token;
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/${token}').set({'token': token});
    setState(() {});
  }

  final homeScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('යමං - Yaman'),
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
        body: _initialPosition == null
            ? Container(
                alignment: Alignment.center,
                child: Center(
                    child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(
                      'Please Enable the Location permission on your phone and try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                )),
              )
            : Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _initialPosition, zoom: 10),
                    onMapCreated: onCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    markers: _markers,
                    onCameraMove: _onCameraMove,
                    polylines: _polyLine,
                  ),
                  Positioned(
                    top: 50.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: locationController,
                        decoration: InputDecoration(
                          icon: Container(
                            margin: EdgeInsets.only(left: 20, top: 5),
                            width: 10,
                            height: 10,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                          ),
                          hintText: "pick up",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 105.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: TextField(
                        onTap: () async {
                          Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: "AIzaSyAeBZue8ZW1DFyghF7Vw-yTkoV1j8FB-eg",
                              language: "en",
                              components: [Component(Component.country, "lk")]);
                          // if(p != null){
                          //   print('place place place : ${p.description}');
                          //   destinationController.text = p.description;
                          // }
                          displayPrediction(p, homeScaffoldKey.currentState);
                        },
                        cursorColor: Colors.black,
                        controller: destinationController,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) {
                          senRequest(value);
                        },
                        decoration: InputDecoration(
                          icon: Container(
                            margin: EdgeInsets.only(left: 20, top: 5),
                            width: 10,
                            height: 10,
                            child: Icon(
                              Icons.local_taxi,
                              color: Colors.black,
                            ),
                          ),
                          hintText: "destination?",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 10,
                    child: FloatingActionButton(
                      heroTag: 'btn2',
                      onPressed: () {
                        createdriverposition();
                      },
                      tooltip: "Sent driver location",
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'btn1',
                      onPressed: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context => )GetMap()));
                        //  locationRemove();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => GetMap()));
                      },
                      tooltip: "Search Customer location",
                      child: Icon(
                        Icons.location_searching,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ));
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void onCreated(GoogleMapController controller) {
    // _startQuery();
    setState(() {
      mapController = controller;
    });
  }

  //add markers in map
  void _onAddMarkerPressed(LatLng location, String address) async {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastPosition.toString()),
          position: location,
          infoWindow: InfoWindow(title: address, snippet: "Go Here"),
          icon: BitmapDescriptor.defaultMarker));

      // _addGeoPoint();
      // sendGeoPoint();
    });
  }

  //move camera
  _animateToUser() async {
    setState(() {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _initialPosition, zoom: 15)));
    });
    // return position;
  }

  Future<void> createdriverposition() async {
    var positions = <String, dynamic>{
      'latitude': _initialPosition.latitude,
      'longitude': _initialPosition.longitude,
      'uid': userId
    };
    _animateToUser();

    return database.push().set(positions);
  }

  void createRoute(String encodedPloyline) {
    setState(() {
      _polyLine.add(
        Polyline(
            polylineId: PolylineId(_lastPosition.toString()),
            width: 10,
            color: Colors.black,
            points: convertToLatLng(_decodePoly(encodedPloyline))),
      );
    });
  }

  // this method convert list of doubles into latlng
  List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void senRequest(String intendeedLocation) async {
    List<prefix0.Placemark> placemark =
        await prefix0.Geolocator().placemarkFromAddress(intendeedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _onAddMarkerPressed(destination, intendeedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);
  }

  void _getUserLocation() async {
    prefix0.Position position = await prefix0.Geolocator().getCurrentPosition(
      desiredAccuracy: prefix0.LocationAccuracy.best,
    );
    List<prefix0.Placemark> placemark = await prefix0.Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      locationController.text = placemark[0].name;
      // createdriverposition();
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
}
