import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_stemic/main.dart';

class ProfilePage extends StatefulWidget {
  FirebaseUser user;
  ProfilePage({Key key, @required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState(user);
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseUser _user;

  _ProfilePageState(@required this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'LogOut',
          icon: Icon(
            Icons.arrow_back,
            semanticLabel: 'LogOut',
          ),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.push(
                context,
                MaterialPageRoute<Future>(
                    builder: (BuildContext context) => MyApp()));
          },
        ),
        title: Text(
          'Home: ' + _user.email,
          style: TextStyle(fontSize: 16),
        ), //${widget.user.email}
      ),
      body: Text(
        'Usuario entrou com sucesso',
        textAlign: TextAlign.center,
      ),
    );
  }
}
