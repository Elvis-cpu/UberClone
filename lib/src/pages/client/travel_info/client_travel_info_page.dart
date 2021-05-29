import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/src/pages/client/travel_info/client_travel_info_controller.dart';


class ClientTravelInfoPage extends StatefulWidget {
  const ClientTravelInfoPage({Key key}) : super(key: key);

  @override
  _ClientTravelInfoPageState createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {

  ClientTravelInfoController _con = new ClientTravelInfoController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    }) ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            child: _googleMapWidget(),
            alignment: Alignment.topCenter,
          ),
        ],
      ),

    );
  }

  Widget _googleMapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
    );
  }


  void refresh() {
    setState(() {});
  }

}
