import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone/src/models/client.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/providers/client_provider.dart';
import 'package:uber_clone/src/providers/driver_provider.dart';
import 'package:uber_clone/src/providers/geofire_provider.dart';
import 'package:uber_clone/src/utils/my_progress_dialog.dart';
import 'package:uber_clone/src/utils/snackbar.dart' as utils;
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';

class ClientMapController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(19.2451224, -103.7163459),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position _position;
  StreamSubscription<Position> _positionStream;

  BitmapDescriptor markerDriver;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ClientProvider _clientProvider;

  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _clientInfoSubscription;

  Client client;

  String from;// origen que esta almacenando
  LatLng fromLatLng; // variable que estara cambiando

  bool isFromSelected = true;

  String to;
  LatLng toLatLng;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = new GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _clientProvider = new ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/uber_car.png');
    checkGPS();
    getClientInfo();
  }

  void getClientInfo() {
    Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser().uid);
    _clientInfoSubscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data());
      refresh();
    });
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _clientInfoSubscription?.cancel();
  }

  void signOut() async {
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }
  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"featureType": "all", "elementType": "labels.text.fill", "stylers": [{"color": "#7c93a3"}, {"lightness": "-10"}]}, {"featureType": "administrative.country", "elementType": "geometry", "stylers": [{"visibility": "on"}]}, {"featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [{"color": "#a0a4a5"}]}, {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#62838e"}]}, {"featureType": "landscape", "elementType": "geometry.fill", "stylers": [{"color": "#dde3e3"}]}, {"featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [{"color": "#3f4a51"}, {"weight": "0.30"}]}, {"featureType": "poi", "elementType": "all", "stylers": [{"visibility": "simplified"}]}, {"featureType": "poi.attraction", "elementType": "all", "stylers": [{"visibility": "on"}]}, {"featureType": "poi.business", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.government", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.park", "elementType": "all", "stylers": [{"visibility": "on"}]}, {"featureType": "poi.place_of_worship", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.school", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.sports_complex", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "road", "elementType": "all", "stylers": [{"saturation": "-100"}, {"visibility": "on"}]}, {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#bbcacf"}]}, {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"lightness": "0"}, {"color": "#bbcacf"}, {"weight": "0.50"}]}, {"featureType": "road.highway", "elementType": "labels", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway", "elementType": "labels.text", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway.controlled_access", "elementType": "geometry.fill", "stylers": [{"color": "#ffffff"}]}, {"featureType": "road.highway.controlled_access", "elementType": "geometry.stroke", "stylers": [{"color": "#a9b4b8"}]}, {"featureType": "road.arterial", "elementType": "labels.icon", "stylers": [{"invert_lightness": true}, {"saturation": "-7"}, {"lightness": "3"}, {"gamma": "1.80"}, {"weight": "0.01"}]}, {"featureType": "transit", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#a3c7df"}]}]'
    );


    _mapController.complete(controller);
  }

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition(); // UNA VEZ
      centerPosition();
      getNearbyDrivers();

    } catch(error) {
      print('Error en la localizacion: $error');
    }
  }

  void changeFromTo(){
    isFromSelected = !isFromSelected;
    if (isFromSelected){
      utils.Snackbar.showSnackbar(context, key, 'Seleccionado el punto de origen');
    } else{
      utils.Snackbar.showSnackbar(context, key, 'Seleccionado el destino');
    }
  }

  Future<Null> setLocationDraggableInfo () async{
    if(initialPosition != null){
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;
      List<Placemark> address = await placemarkFromCoordinates(lat, lng);
      if (address != null){
        if ( address.length > 0) {
          String direction = address[0].thoroughfare;
          String num = address[0].subThoroughfare;
          String city = address[0].locality;
          String department = address[0].administrativeArea;
          String country = address[0].country;

          if (isFromSelected){

            from = '$direction #$num, $city, $department, $country';
            fromLatLng = new LatLng(lat, lng);
            print('From: $from');
            refresh();

          } else {
            to = '$direction #$num, $city, $department, $country';
            toLatLng = new LatLng(lat, lng);
            print('From: $to');
            refresh();
          }

        }
      }
    }
  }

  void getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream =
    _geofireProvider.getNearbyDrivers(_position.latitude, _position.longitude, 50);

    stream.listen((List<DocumentSnapshot> documentList) {

      for (DocumentSnapshot d in documentList) {
        print('DOCUMENT: $d');
      }

      for (MarkerId m in markers.keys) {
        bool remove = true;

        for (DocumentSnapshot d in documentList) {
          if (m.value == d.id) {
            remove = false;
          }
        }

        if (remove) {
          markers.remove(m);
          refresh();
        }

      }

      for (DocumentSnapshot d in documentList) {
        GeoPoint point = d.data()['position']['geopoint'];
        addMarker(
            d.id,
            point.latitude,
            point.longitude,
            'Conductor disponible',
            '',
            markerDriver
        );
      }

      refresh();

    });
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position.latitude, _position.longitude);
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Activa el GPS para obtener la posicion');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      updateLocation();
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        print('ACTIVO EL GPS');
      }
    }

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude, longitude),
              zoom: 14.8
          )
      ));
    }
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {

    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position.heading
    );

    markers[id] = marker;

  }

}