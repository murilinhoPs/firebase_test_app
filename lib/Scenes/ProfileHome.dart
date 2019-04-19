import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_stemic/main.dart';


// Esse código só mostra que o usuário fez login com sucesse pelo FirebaseAuth
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
        // criei o ícone seta para voltar e nele coloquei a rota para voltar para 
        //o menu principal, que é a classe MyApp
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
        // Como título da pagina eu mostro o email que foi cadastrado. Pego do banco de dados do Firebase 
        //e mostro para o usuário.
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
