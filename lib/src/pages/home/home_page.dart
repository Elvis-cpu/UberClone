import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone/src/pages/home/home_controller.dart';

class HomePage extends StatefulWidget {
//diseño
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController _con  = new HomeController();

  @override
  void initState() {
    // TODO: implement initState
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container( // contenedor del column

          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.topLeft,
              colors: [Colors.black, Colors.black87]
            )
          ),

          child: Column(
            children: [

              _bannerApp(context),

              SizedBox(height: 50,),
              _textSelectYourRol(),
              SizedBox(height: 30,),
              _imageTypeUser(context, 'assets/img/pasajero.png', 'client'),
              SizedBox(height: 10,),
              textTypeUser('Cliente'), //cliente

              SizedBox(height: 30,),
              _imageTypeUser(context, 'assets/img/driver.png', 'driver'),
              SizedBox(height: 10,),
              textTypeUser('Conductor')//Conductor
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerApp(BuildContext context){
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.38, // contenerdor del row
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // separacion entre logo y texto
          children: [
            Image.asset('assets/img/logo_app.png', width: 150, height: 100,),
            Text(
              'Viaja seguro',
               style: TextStyle(fontFamily: 'Pacifico', fontSize: 22, fontWeight: FontWeight.bold),)
          ],
        ),
      ),

    );
  }

  Widget _textSelectYourRol(){
    return Text('SELECCIONA TU ROL', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'OneDay'),);
  }

  Widget _imageTypeUser(BuildContext context, String image, String typeUser){
    return GestureDetector(
        onTap: () =>  _con.goToLoginPage(typeUser),
        child: CircleAvatar(backgroundImage: AssetImage(image), radius: 50, backgroundColor: Colors.grey[900],),
    );
  }

  Widget textTypeUser(String typeUser){
    return Text(typeUser, style: TextStyle(color: Colors.white, fontSize: 16));
  }
}
