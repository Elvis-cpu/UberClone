import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone/src/models/client.dart';
import 'package:uber_clone/src/models/driver.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/providers/client_provider.dart';
import 'package:uber_clone/src/providers/driver_provider.dart';
import 'package:uber_clone/src/utils/my_progress_dialog.dart';
import 'package:uber_clone/src/utils/shared_pref.dart';
import 'package:uber_clone/src/utils/snackbar.dart' as utils;

class LoginController {
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  // propiedrad de tipo auth provider
  AuthProvider _authProvider;
  ProgressDialog _progressDialog;
  DriverProvider _driverProvider;
  ClientProvider _clientProvider;

  SharedPref _sharedPref;
  String _typeUser;

  Future init(BuildContext context) async {
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _clientProvider = new ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espero un momento....');
    _sharedPref = new SharedPref();
    _typeUser = await _sharedPref.read('typeUser');

    print(_typeUser);
  }

  void goToRegisterPage(){
    if(_typeUser == 'client') {
      Navigator.pushNamed(context, 'client/register');
    }else{

      Navigator.pushNamed(context, 'driver/register');
    }
  }

// retorna lo que el usuario escribe al momento de escribir
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('Email: $email');
    print('Password: $password');

    _progressDialog.show();

    try {
      bool isLogin = await _authProvider.login(email, password);
      _progressDialog.hide();

      if (isLogin) {
        print('Usuario logueado');

        if(_typeUser == 'client'){
          Client client = await _clientProvider.getById(_authProvider.getUser().uid);
          print('client: $client');
          if(client != null){
            Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
            print('cliente no es nulo');
          }
          else{
            print('cliente es nulo');
            utils.Snackbar.showSnackbar(context, key, 'Usuario no es valido');
            await _authProvider.signOut();
          }
        }
        else  if(_typeUser == 'driver'){
          Driver driver = await _driverProvider.getById(_authProvider.getUser().uid);
          print('driver: $driver');
          if(driver != null){
            Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
            print('driver no es nulo');
          }
          else{
            print('driver es nulo');
            utils.Snackbar.showSnackbar(context, key, 'Usuario no es valido');
            await _authProvider.signOut();
          }
        }
      }
      else {
        utils.Snackbar.showSnackbar(context, key, 'Usuario no auntenticado');
        print('usuario no auntenticado');
      }
    } catch (error) {
      utils.Snackbar.showSnackbar(context, key, 'Error $error');
      _progressDialog.hide();
      print('Error $error');
    }
  }
}
