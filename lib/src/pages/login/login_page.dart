import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone/src/pages/login/login_controller.dart';
import 'package:uber_clone/src/utils/colors.dart' as utils;
import 'package:uber_clone/src/widgets/button_app.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isHidden = true;

  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  LoginController _con = new LoginController();

  // controllador inicializado para un stateful
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
      key: _con.key,
      //etiqueta principal
      appBar: AppBar(), // creacion del appbar
      body: SingleChildScrollView( //nuevo
        child: Column(
          children: [
            _bannerApp(), //imagenes y letras
            SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
            _textLogin(), // login// nuevo
            _textFieldEmail(), //input correo
            _textFieldPassword('Contraseña'),
            _buttomLogin(),
            _textDontHaveAccount()
          ],
        ),
      ),
    );
  }

  Widget _buttomLogin() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25), // alinear el boton
      child: ButtonApp(
        onPressed: _con.login,
        text: 'Iniciar sesión',
        color: utils.Colors.uberCloneColor,
        textColor: Colors.white,),
    );
  }

  Widget _textDontHaveAccount() {
    return  Container(
        margin: EdgeInsets.only(bottom: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('¿No tienes cuenta?'),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: _con.goToRegisterPage,
              child: Text(
                'Resgistrarse',
                style: TextStyle(
                    color: utils.Colors.uberCloneColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      );

  }

  Widget _textFieldEmail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController, // retorna en el teclado lo que escribe
        decoration: InputDecoration(
            labelText:  'Correo Electronico',
            labelStyle: TextStyle(
                fontSize: 16, fontFamily: 'NimbusSans', color: Colors.grey[600]
            ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: utils.Colors.uberCloneColor, width: 2),
          ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.grey[600],
            ),
        ),
      ),
    );
  }
  Widget _textFieldPassword(  String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        controller: _con.passwordController,

        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 16, fontFamily: 'NimbusSans', color: Colors.grey[600]
            ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: utils.Colors.uberCloneColor, width: 2),
          ),
         // enabledBorder: OutlineInputBorder(
         //   borderSide: BorderSide(color: utils.Colors.uberCloneColor),
        //  ),
          prefixIcon: labelText == "Contraseña" ? IconButton(
                icon: _isHidden ? Icon(Icons.lock_outlined) : Icon(Icons.lock_open_outlined),
                color: Colors.grey[600],
                onPressed: _toggleVisibility
            ) : null,

          suffixIcon: labelText == "Contraseña" ? IconButton(
            onPressed: _toggleVisibility,
            icon: _isHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
            color: Colors.grey[600],
          )  : null ,

        ),

        obscureText: labelText == 'Contraseña' ? _isHidden : false,
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        children: [
          Text(
            'Bienvenido!',
            style: TextStyle(

                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 40
            ),
          ),
          SizedBox(height: 2,),
          Text('Iniciar sesión para continuar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),

    );
  }



  Widget _bannerApp() {
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
        color: utils.Colors.uberCloneColor, //color del banner
        //height: MediaQuery.of(context).size.height * 0.2, // contenerdor del row
        height: MediaQuery.of(context).size.height * 0.30, // contenerdor del row
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start, //centrar contenido de forma vertical
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
          // separacion entre logo y texto
          children: [
            Image.asset(
              'assets/img/logo_app.png',
              width: 150,
              height: 100,

            ),

            Text(
              'Viaja seguro',
              style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );


  }
}

