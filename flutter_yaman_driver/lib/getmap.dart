import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'app_screen/diverlogin.dart';

class GetMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GetMapState();
  }
}

class GetMapState extends State<GetMap> {
  static const _initialPosition = LatLng(6.7185992, 80.7879343);
  GoogleMapController mapController;

  LatLng _lastPosition = _initialPosition;

  final Set<Marker> _markers = {};

  Location location = new Location();
  Firestore firestore = Firestore.instance;
  // Geoflutterfire geo = Geoflutterfire();
  static String userId;

  final DatabaseReference database = FirebaseDatabase.instance
      .reference()
      .child('Uber')
      .child('customers_geoPoint');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) => {
          if (currentUser == null)
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Driverlogin()))
            }
          else
            {getDriversMarkers(), userId = currentUser.uid}
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Map'),
      ),
      body: Stack(
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
          )
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
        if (userId == values['uid']) {
          print('${values["latitude"]}/${values["longitude"]}');
          var markers = Marker(
              markerId:
                  MarkerId('${values["latitude"]} ${values["longitude"]}'),
              position: LatLng(values["latitude"], values["longitude"]),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: 'Magic Marker', snippet: 'buhaha'));
          _markers.add(markers);
        }
      });
      print('markersssss: $_markers');
    });
  }
}
