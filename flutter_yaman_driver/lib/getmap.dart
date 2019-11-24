import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  final DatabaseReference database = FirebaseDatabase.instance
      .reference()
      .child('Uber')
      .child('drivers_geoPoint');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDriversMarkers();

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
    database.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      print(values);

      values.forEach((key,values){
        print('${values["latitude"]}/${values["longitude"]}');
        var markers = Marker(
          markerId: MarkerId('${values["latitude"]} ${values["longitude"]}'),
          position: LatLng(values["latitude"], values["longitude"]),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: 'Magic Marker',
            snippet: 'buhaha'
          )
        );
        _markers.add(markers);
      });
      print('markersssss: $_markers');
    });
  }

  // void _updateMarkers(List<DocumentSnapshot> documentList) {
  //   print(documentList);
  //   //_markers.clear();
  //   documentList.forEach((DocumentSnapshot document) {
  //     GeoPoint pos = document.data['position']['geopoint'];
  //     double distance = document.data['distance'];
  //     print('nooooo hello' + pos.toString());
  //     var markers = Marker(
  //       markerId: MarkerId(pos.toString()),
  //       position: LatLng(pos.latitude, pos.latitude),
  //       icon: BitmapDescriptor.defaultMarker,
  //       infoWindow: InfoWindow(
  //           title: 'Magic Marker',
  //           snippet: '$distance kilometers from query center'),
  //     );
  //     _markers.add(markers);
  //   });
  // }

  // _startQuery() async {
  //   //get user location
  //   var pos = await location.getLocation();
  //   double lat = pos.latitude;
  //   double lng = pos.longitude;

  //   //make refernce to firestore
  //   var ref = firestore.collection('locations');
  //   GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

  //   //subscribe to query
  //   subscription = radius.switchMap((mapper) {
  //     return geo
  //         .collection(collectionRef: ref)
  //         .within(center: center, radius: mapper, field: 'position',strictMode: true);
  //   }).listen(_updateMarkers);
  // }

  // void _updateQuery(double value) {
  //   final zoomMap = {
  //     100.0: 12.0,
  //     200.0: 10.0,
  //     300.0: 7.0,
  //     400.0: 6.0,
  //     500.0: 5.0
  //   };

  //   final zoom = zoomMap[value];
  //   mapController.moveCamera(CameraUpdate.zoomTo(zoom));

  //   setState(() {
  //     radius.add(value);
  //   });
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   subscription.cancel();
  //   super.dispose();
  // }

}
