import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone/src/models/client.dart';
import 'package:uber_clone/src/providers/auth_provider.dart';
import 'package:uber_clone/src/providers/client_provider.dart';
import 'package:uber_clone/src/utils/my_progress_dialog.dart';
import 'package:uber_clone/src/utils/snackbar.dart' as utils;

class ClientRegisterController {

  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  // propiedrad de tipo auth provider
  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  ProgressDialog _progressDialog; //

  Future init(BuildContext context) {
    this.context = context;
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espero un momento....');
  }

// retorna lo que el usuario escribe al momento de escribir
  void Register() async {
    String usename = usernameController.text.trim();
    String email = emailController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String password = passwordController.text.trim();

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
        Client client = new Client(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: usename,
          password: password
        );



        await _clientProvider.create(client);
        _progressDialog.hide();
        Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
        print('Usuario Registrado');

        utils.Snackbar.showSnackbar(context, key, 'Usuario Registrado');
      } else {

        _progressDialog.hide();
        print('usuario no se pudo registrar');
      }
    } catch (error) {
      if(email == email.isNotEmpty ){}
      utils.Snackbar.showSnackbar(context, key, 'Error $error');
      print('Error $error');
    }
  }
}
