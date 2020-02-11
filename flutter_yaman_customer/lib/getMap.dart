import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_yaman_driver/request/google_map_request.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class GetMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GetMapState();
  }
}

GoogleMapsPlaces _places =
    new GoogleMapsPlaces(apiKey: "AIzaSyAeBZue8ZW1DFyghF7Vw-yTkoV1j8FB-eg");

class GetMapState extends State<GetMap> {
  // static const _initialPosition = LatLng(6.7185992, 80.7879343);
  GoogleMapController mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  static LatLng _initialPosition;
  static String dirverId;

  LatLng _lastPosition = _initialPosition;
  //markers
  final Set<Marker> _markers = {};
  //polyline
  final Set<Polyline> _polyLine = {};

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController driverController = TextEditingController();
  final homeScaffoldKey = new GlobalKey<ScaffoldState>();

  final DatabaseReference database = FirebaseDatabase.instance
      .reference()
      .child('Uber')
      .child('drivers_geoPoint');
      

  final DatabaseReference database1 = FirebaseDatabase.instance
      .reference()
      .child('Uber')
      .child('customers_geoPoint');

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
    // getDriversMarkers();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Text('Drivers Map'),
      ),
      body: _initialPosition == null
          ? Container(
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Please Enable the Location permission on your phone and try again',textAlign: TextAlign.center,style: TextStyle(fontSize: 18),)
                  ],
                )
              ),
            )
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialPosition, zoom: 15),
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
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
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
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 5,
                  child: FloatingActionButton(
                    heroTag: 'btn2',
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => GetMap()));
                      // createdriverposition();
                      getDriversMarkers();
                    },
                    tooltip: "Available Drivers",
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 5
                  ,
                  child: FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => GetMap()));
                      // createdriverposition();
                      callTodriverposition();
                    },
                    tooltip: "call to Drivers",
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                ),
                Positioned(
                  bottom:35.0,
                  right: 60.0,
                  left: 60.0,
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
                      controller: driverController,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        senRequest(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Tap the driver marker",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void onCreated(GoogleMapController controller) {
    //  _startQuery();
    getDriversMarkers();
    setState(() {
      mapController = controller;
    });
  }

  getDriversMarkers() {
    database.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      print(values);

      values.forEach((key, values) {
        print('${values["latitude"]}/${values["longitude"]}');
        var markers = Marker(
            markerId: MarkerId('${values["latitude"]} ${values["longitude"]}'),
            position: LatLng(values["latitude"], values["longitude"]),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: 'Drivers', snippet: 'Place Details'),
            onTap: () {
              driverController.text =
                  '${values["latitude"]} /${values["longitude"]}';
                  _initialPosition = LatLng(values["latitude"], values["longitude"]);
                  dirverId = values['uid'];
            });
        _markers.add(markers);
      });
      print('markersssss: $_markers');
    });
  //  onCreated(mapController);
  }

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      locationController.text = placemark[0].name;
      // createdriverposition();
    });
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
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendeedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    // _onAddMarkerPressed(destination, intendeedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);
  }

 //call driver - sent customer data into driver
  Future<void> callTodriverposition() async{
    var positions = <String,dynamic>{
      'latitude': _initialPosition.latitude,
      'longitude': _initialPosition.longitude,
      'uid': dirverId
    };
   // _animateToUser();
    return database1.push().set(positions);

  }
}
