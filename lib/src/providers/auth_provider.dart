import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider{

  FirebaseAuth _firebaseAuth;
  BuildContext context;


  //cracion del constructor
  AuthProvider(){
    _firebaseAuth = FirebaseAuth.instance;
  }
// retorna los datos en firebase
  User getUser(){
    return _firebaseAuth.currentUser;
  }

  bool isSignedIn(){
    final currentUser = _firebaseAuth.currentUser;
    if(currentUser == null){
      return false;
    }
    return true;
  }

  void checkIfUserIsLogged(BuildContext context, String typeUser){
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if(user != null && typeUser != null){
        if(typeUser == 'client'){

          print('Usuario logueado');
          Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);
        }else {
          print('Usuario logueado');
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
        }
      }else{
        print('Usuario no esta logueado');

      }
    });
  }

  // crear un metodo para logeardo con firebase
  Future<bool> login(String email, String password) async {
    String errorMessage;

    try{

      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    }catch(error){
      print(error);

      errorMessage = error.code;

    }

    if(errorMessage != null){
      return Future.error(errorMessage );
    }
    return true;

  }

  Future<bool> register(String email, String password) async {
    String errorMessage;

    try{

      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    }catch(error){
      print(error);

      errorMessage = error.code;

    }

    if(errorMessage != null){
      return Future.error(errorMessage );
    }
    return true;

  }

  Future<void> signOut() async{
    return Future.wait([_firebaseAuth.signOut()]);

  }

}