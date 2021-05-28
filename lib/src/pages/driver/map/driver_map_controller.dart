import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone/src/models/driver.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/providers/driver_provider.dart';
import 'package:uber_clone/src/providers/geofire_provider.dart';
import 'package:uber_clone/src/utils/my_progress_dialog.dart';
import 'package:uber_clone/src/utils/snackbar.dart' as utils;

class DriverMapController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosotion = CameraPosition(
    target: LatLng(19.2451224, -103.7163459),
    zoom: 14.0,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position _position;
  StreamSubscription<Position> _positionStream;

  Driver driver;

  BitmapDescriptor markerDriver;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;

  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    _geofireProvider  = new  GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    markerDriver = await createMarkerImageFromAsset('assets/img/uber_car.png');
    checkGPS();
    getDriverInfo();

  }



  void getDriverInfo () {
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser().uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }

  void dispose () {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
  }

  void signOut () async{
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"featureType": "all", "elementType": "labels.text.fill", "stylers": [{"color": "#7c93a3"}, {"lightness": "-10"}]}, {"featureType": "administrative.country", "elementType": "geometry", "stylers": [{"visibility": "on"}]}, {"featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [{"color": "#a0a4a5"}]}, {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#62838e"}]}, {"featureType": "landscape", "elementType": "geometry.fill", "stylers": [{"color": "#dde3e3"}]}, {"featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [{"color": "#3f4a51"}, {"weight": "0.30"}]}, {"featureType": "poi", "elementType": "all", "stylers": [{"visibility": "simplified"}]}, {"featureType": "poi.attraction", "elementType": "all", "stylers": [{"visibility": "on"}]}, {"featureType": "poi.business", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.government", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.park", "elementType": "all", "stylers": [{"visibility": "on"}]}, {"featureType": "poi.place_of_worship", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.school", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "poi.sports_complex", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "road", "elementType": "all", "stylers": [{"saturation": "-100"}, {"visibility": "on"}]}, {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#bbcacf"}]}, {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"lightness": "0"}, {"color": "#bbcacf"}, {"weight": "0.50"}]}, {"featureType": "road.highway", "elementType": "labels", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway", "elementType": "labels.text", "stylers": [{"visibility": "on"}]}, {"featureType": "road.highway.controlled_access", "elementType": "geometry.fill", "stylers": [{"color": "#ffffff"}]}, {"featureType": "road.highway.controlled_access", "elementType": "geometry.stroke", "stylers": [{"color": "#a9b4b8"}]}, {"featureType": "road.arterial", "elementType": "labels.icon", "stylers": [{"invert_lightness": true}, {"saturation": "-7"}, {"lightness": "3"}, {"gamma": "1.80"}, {"weight": "0.01"}]}, {"featureType": "transit", "elementType": "all", "stylers": [{"visibility": "off"}]}, {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#a3c7df"}]}]'
    );
    _mapController.complete(controller);
  }

  Future animateCamaraToPsition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(latitude, longitude),
            zoom: 14.8,
          ),
        ),
      );
    }
  }

  void openDrawer(){
    key.currentState.openDrawer();
  }

  void centerPosition() {
    if (_position != null) {
      animateCamaraToPsition(_position.latitude, _position.longitude);
    } else {
      utils.Snackbar.showSnackbar(context, key, 'Activar GPS');
    }
  }

  void saveLocation ()async {
    await _geofireProvider.create(_authProvider.getUser().uid, _position.latitude, _position.longitude);
    _progressDialog.hide();
  }

  void connect(){
    if (isConnect) {
      disconnect();
    }else{
      _progressDialog.show();
      updateLocation();
    }
  }

  void disconnect () {
    _positionStream?.cancel();
    _geofireProvider.delete(_authProvider.getUser().uid);

  }

  void checkIfIsConnect(){
    Stream<DocumentSnapshot> status = _geofireProvider.getLocationByIdStream(_authProvider.getUser().uid);
    _statusSuscription = status.listen((DocumentSnapshot document) {
      if (document.exists) {
        isConnect = true;
      }else {
        isConnect = false;
      }

      refresh();

    });
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition(); // obtener la ultima posicion ubicado
      centerPosition();
      saveLocation();

      addMarker('driver', _position.latitude, _position.longitude,
          'Tu posicion', '', markerDriver);

      refresh();
      _positionStream = Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ).listen((Position position) {
        _position = position;
        addMarker(
            'Driver', _position.latitude, _position.longitude,
            'Tu posicion', '', markerDriver);
        animateCamaraToPsition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();
      });
    } catch (error) {
      print('Error enla localizacion $error');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS activado');
      updateLocation();
      checkIfIsConnect();
    } else {
      print('GPS no activado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        checkIfIsConnect();
        print('activo gps');

      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Los servicios de ubicación están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Se niegan los permisos de ubicación');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Los permisos de ubicación se niegan permanentemente, no podemos solicitar permisos.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }


//crearun marcador des una imagen
  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

// agregar un marcador
  void addMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor iconMarker) {
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
      rotation: _position.heading,

    );
    // añadimos nuevo marcador


    markers.clear();
    markers[id] = marker;

  }
}
