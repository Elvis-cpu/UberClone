import 'package:flutter/material.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/utils/shared_pref.dart';

class HomeController{

  BuildContext context;
  SharedPref _sharedpref;
  String _typeUser;

  AuthProvider _authProvider;

  //logica de nuestro controllador cambiar ventana

  Future init(BuildContext context) async{
    this.context = context;
    _sharedpref =  new SharedPref();
    _authProvider = new AuthProvider();
    _typeUser = await _sharedpref.read('typeUser');
    checkIfUserIsAuth();

  }

  void checkIfUserIsAuth(){
    bool isSigned = _authProvider.isSignedIn();
    if (isSigned) {
      print('Usuario Logueado');
      if (_typeUser == 'client') {
        Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
      }else{
        Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
      }
    }else{

      print('Usuario no esta Logueado');
    }
  }

  void goToLoginPage(String typeUser){
    saveTypeUser(typeUser);
    Navigator.pushNamed(context, 'login');
  }

  void saveTypeUser (String typeUser) async{
    await _sharedpref.save('typeUser', typeUser);
  }


}