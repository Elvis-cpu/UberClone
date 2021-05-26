import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone/src/models/driver.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/providers/driver_provider.dart';
import 'package:uber_clone/src/utils/my_progress_dialog.dart';
import 'package:uber_clone/src/utils/snackbar.dart' as utils;

class DriverRegisterController {

  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller = new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();
  TextEditingController pin7Controller = new TextEditingController();


  // propiedrad de tipo auth provider
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ProgressDialog _progressDialog; //

  Future init(BuildContext context) {
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espero un momento....');
  }

// retorna lo que el usuario escribe al momento de escribir
  void Register() async {
    String usename = usernameController.text.trim();
    String email = emailController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String password = passwordController.text.trim();
    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();
    String pin7 = pin7Controller.text.trim();

    String plate = '$pin1$pin2$pin3$pin4$pin5$pin6$pin7';

    print('Email: $email');
    print('Password: $password');

    if (usename.isEmpty && email.isEmpty && password.isEmpty && confirmPassword.isEmpty){
      print('El usuario debe ingresar todo los campos');
      utils.Snackbar.showSnackbar(context, key, 'El usuario debe ingresar todo los campos');

      return;
    }

    if (confirmPassword != password) {
      print('Las contraseñas no coinciden ');
      utils.Snackbar.showSnackbar(context, key, 'Las contraseñas no coinciden');
      return;
    }

    if (password.length < 8 ){
      print('La contraseña debe tener al menos 8 caracteres ');
      utils.Snackbar.showSnackbar(context, key, 'La contraseña debe tener al menos 8 caracteres');
      return;
    }

    _progressDialog.show();


    try {
      bool isRegister = await _authProvider.register(email, password);

      if (isRegister) {
        Driver driver = new Driver(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: usename,
          password: password,
          plate: plate,
        );



        await _driverProvider.create(driver);
        _progressDialog.hide();
        Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);

        print('Usuario Registrado');
        utils.Snackbar.showSnackbar(context, key, 'Usuario Registrado');
      } else {

        _progressDialog.hide();
        print('usuario no se pudo registrar');
      }
    } catch (error) {
      utils.Snackbar.showSnackbar(context, key, 'Error $error');
      print('Error $error');
    }
  }
}
