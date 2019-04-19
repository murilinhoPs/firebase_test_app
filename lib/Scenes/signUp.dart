import 'package:fire_stemic/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CriarConta extends StatefulWidget {
  @override
  _CriarContaState createState() => _CriarContaState();
}

class _CriarContaState extends State<CriarConta> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password, _nameId;
  FirebaseUser user;

  Color gradientStart = Colors.purple[700];
  Color gradientFinal = Colors.purple[400];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: Stack(children: <Widget>[
          // coloquei em Stack para os elementos poderem se sobrepor, os elementos de login se sobreporem nesse background

          // É o container que muda a cor do fundo, o gradiente roxo. Apenas decoração
          Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientFinal, gradientStart],
              begin: const FractionalOffset(0.0, 1.0),
              end: const FractionalOffset(0.0, 0.4),
            ),
          )),
          // Center element para poder centralizar os elemtos aqui dentro. Width and Height Factor é como uma margem, para nao ficar totalmente centralizado, apenas usei o centro de referencia para ajustar a sua posicao a partir do centro
          Container(alignment: Alignment.center, child: loginCard(context)),
        ]));
  }

  Widget loginCard(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          width: 325,
          decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10),
              color: Colors.white70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  // emailInput
                  width: 280,
                  padding: EdgeInsets.only(top: 15),
                  child: emailTextInput(context)),
              Container(
                  // senhaInput
                  width: 280,
                  padding: EdgeInsets.only(top: 15),
                  child: passwordTextInput(context)),
              Container(
                  // Login Button
                  width: 220,
                  padding: EdgeInsets.only(top: 15),
                  child: RaisedButton(
                    color: Colors.deepPurple[400],
                    child: Text(
                      ('Cadastrar'),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      signUp();
                    }, //signIn,
                  )),
              Container(
                height: 10,
              ),
            ],
          ),
        ));
  }

  Widget nameTextInput(BuildContext context) {
    return TextFormField(
      // Style
      cursorColor: Colors.purple,
      cursorWidth: 2.0,
      decoration: InputDecoration(
          hintText: 'E-mail',
          prefixIcon: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 3),
            margin: EdgeInsets.only(right: 6.5),
            child: Icon(Icons.person),
          ),
          //icon: Icon(Icons.email,),
          filled: true,
          fillColor: Colors.white70),
      // Proprieties
      validator: (String input) {
        if (input.isEmpty) {
          return 'Digie um nome válido';
        }
      },
      onSaved: (String input) => _nameId = input,
    );
  }

  Widget emailTextInput(BuildContext context) {
    return TextFormField(
      // Style
      cursorColor: Colors.purple,
      cursorWidth: 2.0,
      decoration: InputDecoration(
          hintText: 'E-mail',
          prefixIcon: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 3),
            margin: EdgeInsets.only(right: 6.5),
            child: Icon(Icons.person),
          ),
          //icon: Icon(Icons.email,),
          filled: true,
          fillColor: Colors.white70),
      // Proprieties
      validator: (String input) {
        if (input.isEmpty) {
          return 'Digie um email válido';
        }
      },
      onSaved: (String input) => _email = input,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget passwordTextInput(BuildContext context) {
    return TextFormField(
      // Style
      obscureText: true,
      cursorColor: Colors.purple,
      decoration: InputDecoration(
          hintText: 'Senha',
          prefixIcon: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 3),
            margin: EdgeInsets.only(right: 6.5),
            child: Icon(Icons.lock),
          ),
          //icon: Icon(Icons.email,),
          filled: true,
          fillColor: Colors.white70),
      // Proprieties
      validator: (String input) {
        if (input.length < 6) {
          return 'Digite uma senha com 6 ou mais caracteres';
        }
      },
      onSaved: (String input) => _password = input,
    );
  }

  Future<void> signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        user.sendEmailVerification();
        mostrarAviso();
        //Navigator.pushNamed(context, '/profile');
      } catch (e) {
        print(e.message);
      }
    }
  }

  void mostrarAviso() {
    String title, body;
    title = 'Verificação de Email';
    body = 'Você recebeu uma confirmação no seu e-mail, cheque para se cadastrar';
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(body + ' ' + user.email),
              actions: <Widget>[
                FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context, 'Ok');
                      Navigator.push(
                          context,
                          MaterialPageRoute<Future>(
                              builder: (BuildContext context) => MyApp()));
                    })
              ],
            ));
  }
}
