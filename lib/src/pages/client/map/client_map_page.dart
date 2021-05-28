import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/src/pages/client/map/client_map_controller.dart';
import 'package:uber_clone/src/widgets/button_app.dart';



class ClientMapPage extends StatefulWidget {
  const ClientMapPage({Key key}) : super(key: key);
  @override
  _ClientMapPageState createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {


  ClientMapController _con = new ClientMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    }) ;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('Se ejecuto el dispose');
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: Stack(
        children: [
          _googleMapWidget(),
          SafeArea(
            child: Column(
              children: [
                _buttonDrawer(),
                _cardGooglePlace(),
                _buttonChangeTo(),
                _buttonCenterPosition(),
                Expanded(child: Container()),
                _buttonResquest(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _iconMyLocation(),
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
      onCameraMove: (position) {
        _con.initialPosition = position;
        print('on camara move $position');
      },
      onCameraIdle: () async {
        await _con.setLocationDraggableInfo();
      },

    );
  }

  Widget _cardGooglePlace (){
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment:  CrossAxisAlignment.start,
            children: [
              Text('desde', style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              ),
              Text(_con.from ?? '', style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
                maxLines: 2,
              ),
               SizedBox(height: 5,),
               Divider(color: Colors.grey, height: 10,),
              SizedBox(height: 5,),
              Text('Hasta', style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              ),
              Text(_con.to ?? '', style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }


  void refresh() {
    setState(() {});
  }

  Widget _buttonResquest() {
    return Container(
      height: 50,
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed:(){},
        text: 'Solicitar',
        color: Colors.black ,
        textColor: Colors.white,
      ),
    );
  }

  Widget _buttonDrawer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonChangeTo() {
    return GestureDetector(
      onTap: _con.changeFromTo,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.refresh,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    _con.client?.username ?? 'Nombre de usuario',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),

                Container(
                  child: Text(
                    _con.client?.email  ?? 'correo',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10,),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/img/profile.jpg'),
                  radius: 40,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
          ),
          ListTile(
            title: Text(
                'Editar Perfil'),
            trailing: Icon(Icons.edit),
            onTap: () {},
          ),
          ListTile(
            title: Text('Cerrar sesión'),
            trailing: Icon(Icons.power_settings_new),
            onTap: _con.signOut,
          ),
        ],
      ),
    );
  }

  Widget _iconMyLocation (){
    return Image.asset('assets/img/pin.png', width: 38, height: 38,);


  }

}
