import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/src/pages/client/map/client_map_page.dart';
import 'package:uber_clone/src/pages/driver/map/driver_map_page.dart';
import 'package:uber_clone/src/pages/driver/register/driver_register_page.dart';
import 'package:uber_clone/src/pages/home/home_page.dart';
import 'package:uber_clone/src/pages/login/login_page.dart';
import 'package:uber_clone/src/pages/client/register/client_register_page.dart';
import 'package:uber_clone/src/utils/colors.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(UberClone());
}

class UberClone extends StatefulWidget {
  @override
  _UbercloneState createState() => _UbercloneState();
}

class _UbercloneState extends State<UberClone> {


  @override 
  //
  Widget build(BuildContext context) {
    return   MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Uber Clone',
      initialRoute: 'home',
      theme: ThemeData(
          fontFamily: 'NimbusSans',
          appBarTheme: AppBarTheme(elevation: 0),
          primaryColor: utils.Colors.uberCloneColor), // letra y appbar de nuestra app invisible
      routes: {
        'home': (BuildContext context) => HomePage(),
        'login': (BuildContext context) => LoginPage(),
        'client/register': (BuildContext context) => ClientRegisterPage(),
        'driver/register': (BuildContext context) => DriverRegisterPage(),
        'driver/map': (BuildContext context) => DriverMapPage(),
        'client/map': (BuildContext context) => ClientMapPage(),
      },
    );
  }
}
