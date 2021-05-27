import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GeofireProvider {
  CollectionReference _reference;
  Geoflutterfire _geoflutterfire;

  GeofireProvider() {
    _reference = FirebaseFirestore.instance.collection('Locations');
    _geoflutterfire = Geoflutterfire();
  }

  Stream<DocumentSnapshot> getLocationByIdStream(String id){
    return _reference.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void>  create(String id , double lat, double lng){
    GeoFirePoint myLocation = _geoflutterfire.point(latitude: lat, longitude: lng);
    return _reference.doc(id).set({'status': 'Driver_diponibles', 'position': myLocation.data});


  }

  Future<void> delete(String id) {
    return _reference.doc(id).delete();
  }

}