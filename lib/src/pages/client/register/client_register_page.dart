import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone/src/pages/client/register/client_register_controller.dart';
import 'package:uber_clone/src/utils/colors.dart' as utils;
import 'package:uber_clone/src/widgets/button_app.dart';


class ClientRegisterPage extends StatefulWidget {

  @override
  _ClientRegisterPageState createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  bool _isHidden =true;
  bool _isHidden1 =true;

  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }
  void _togglesVisibility(){
    setState(() {
      _isHidden1 = !_isHidden1;
    });
  }
  ClientRegisterController _con = new ClientRegisterController();

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
    //metodo scaffold
    return Scaffold(
      key: _con.key,
      //etiqueta principal
      appBar: AppBar(), // creacion del appbar
      body: SingleChildScrollView( //nuevo
        child: Column(
          children: [
            _bannerApp(), //imagenes y letras
            _textLogin(), // login
            _textFieldUserName(),
            _textFieldEmail(), //input correo
            _textFieldPassword('Contraseña'),
            _textFieldConfirmPassword('Confirmar contraseña'),
            _buttonRegister()
          ],
        ),
      ),
    );
  }

  Widget _buttonRegister() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25), // alinear el boton
      child: ButtonApp(
        onPressed: _con.Register,
        text: 'Registrarse',
        color: utils.Colors.uberCloneColor,
        textColor: Colors.white,),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController, // retorna en el teclado lo que escribe
        decoration: InputDecoration(
            labelText: 'Correo Electronico',
            labelStyle: TextStyle(
                fontSize: 16,
                fontFamily: 'NimbusSans',
                color: Colors.grey[600]
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
            )),
      ),
    );
  }
  Widget _textFieldUserName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController, // retorna en el teclado lo que escribe
        decoration: InputDecoration(
            labelText: 'Nombre completo',
            labelStyle: TextStyle(
                fontSize: 16,
                fontFamily: 'NimbusSans',
                color: Colors.grey[600]
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: utils.Colors.uberCloneColor, width: 2),
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
            )),
      ),
    );
  }

  Widget _textFieldPassword(String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.passwordController,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'NimbusSans',
            color:  Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: utils.Colors.uberCloneColor, width: 2),
          ),
          prefixIcon: labelText == 'Contraseña' ? IconButton(
            icon: _isHidden1 ? Icon(Icons.lock_outline) : Icon(Icons.lock_open_outlined),
            color:  Colors.grey[600],
            onPressed: _togglesVisibility,
          ) : null,
          suffixIcon: labelText == 'Contraseña' ? IconButton(
            icon: _isHidden1 ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
            color:  Colors.grey[600],
            onPressed: _togglesVisibility,
          ) : null,

        ),
        obscureText: labelText == 'Contraseña' ? _isHidden1 : false,
      ),
    );
  }



  Widget _textFieldConfirmPassword(String labelText) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.confirmPasswordController,

        decoration: InputDecoration(

            labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'NimbusSans',
            color:  Colors.grey[600],
          ),
          border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(20),

            ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: utils.Colors.uberCloneColor, width: 2),
          ),
          prefixIcon: labelText == 'Confirmar contraseña' ? IconButton(
            color:  Colors.grey[600],
            icon:_isHidden ? Icon(Icons.lock_outline) : Icon(Icons.lock_open_outlined),
            onPressed: _toggleVisibility,
          ) : null,
          suffixIcon: labelText == 'Confirmar contraseña' ? IconButton(
              icon:_isHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
              color:  Colors.grey[600],
              onPressed: _toggleVisibility,
              ) : null,
        ),
        obscureText: labelText == 'Confirmar contraseña' ? _isHidden : false,
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Text(
        'Crear cuenta',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
      ),
    );
  }



  Widget _bannerApp() {
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: utils.Colors.uberCloneColor, //color del banner
        height: MediaQuery.of(context).size.height * 0.2, // contenerdor del row
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start, //centrar contenido de forma vertical
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // separacion entre logo y texto
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